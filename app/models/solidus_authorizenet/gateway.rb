# frozen_string_literal: true

module SolidusAuthorizenet
  ##
  # Gateway
  #
  # This gateway is intended to bridge Solidus and AuthorizeNet API. It handles
  # creation of customers, authorizarion of payments, voiding and refunding.
  #
  # If a customer is already created inside authorize net with same email/merchantCustomerId
  # then that customer is reused.
  class Gateway
    ##
    # Init
    #
    # Inits the gateway with provided gateway options (those set in admin)
    def initialize(options)
      @options = options
    end

    ##
    # Client
    #
    # Returns an AuthorizeNet client configured to either sandbox or production
    # environment
    def client
      ::AuthorizeNet::API::Transaction.new(@options[:api_login_id],
                                           @options[:api_transaction_key],
                                           gateway: @options[:test_mode] ? :sandbox : :production)
    end

    ##
    # Get Customer
    #
    # Requests a customer using an authorize.net customer id. Returns info about
    # the customer and their payment profiles.
    def get_customer(customer_profile_id)
      request = ::AuthorizeNet::API::GetCustomerProfileRequest.new
      request.customerProfileId = customer_profile_id

      response = client.get_customer_profile(request)
      success = response.messages.resultCode == ::AuthorizeNet::API::MessageTypeEnum::Ok

      return nil unless success

      payment_profiles = []
      response.profile.paymentProfiles.each do |payment_profile|
        payment_profiles << {
          id: payment_profile.customerPaymentProfileId
        }
      end

      {
        id: request.customerProfileId,
        user_id: response.profile.merchantCustomerId,
        payment_profiles: payment_profiles
      }
    end

    ##
    # Create Customer
    #
    # Creates a customer and a payment profile in authorize.net. Returns
    # customer id.
    def create_customer(payment)
      order = payment.order
      email = order.user&.email || order.email
      user_id = order.user&.id || "guest-#{order.id}"

      payment_profile = ::AuthorizeNet::API::CustomerPaymentProfileType.new
      payment_profile.payment = ::AuthorizeNet::API::PaymentType.new
      payment_profile.payment.opaqueData = ::AuthorizeNet::API::OpaqueDataType.new(payment.source.data_descriptor,
                                                                                   payment.source.data_value)

      request = ::AuthorizeNet::API::CreateCustomerProfileRequest.new

      request.profile = ::AuthorizeNet::API::CustomerProfileType.new
      request.profile.merchantCustomerId = user_id
      request.profile.email = email

      request.profile.paymentProfiles = [payment_profile]

      request.validationMode = ::AuthorizeNet::API::ValidationModeEnum::LiveMode
      request.validationMode = ::AuthorizeNet::API::ValidationModeEnum::TestMode if @options[:test_mode]

      response = client.create_customer_profile(request)

      error_code = response.messages&.messages&.first&.code
      error_text = response.messages&.messages&.first&.text

      Rails.logger.info "#{error_code}: #{error_text}" if error_code.present?

      return error_text.delete('^0-9') if error_code == 'E00039'

      response.customerProfileId
    end

    ##
    # Handle response
    #
    # Handles a response after calling authorize net to simplifly
    # reguired ActiveMerchant response object
    def handle_response
      result = yield

      if result.is_a?(TrueClass) && result
        ::ActiveMerchant::Billing::Response.new(true, 'Transaction succeeded')
      elsif result.is_a?(Hash)
        ::ActiveMerchant::Billing::Response.new(true, 'Transaction succeeded', {}, result)
      else
        ::ActiveMerchant::Billing::Response.new(false, 'Transaction failed')
      end
    end

    ##
    # Authorize
    #
    # Authorizes a payment to be settled at later time
    def authorize(amount, source, order = {})
      handle_response do
        customer = get_customer(source.customer_id)
        return false if customer.nil?

        request = ::AuthorizeNet::API::CreateTransactionRequest.new

        request.transactionRequest = ::AuthorizeNet::API::TransactionRequestType.new
        request.transactionRequest.amount = amount / 100.0

        request.transactionRequest.profile = ::AuthorizeNet::API::CustomerProfilePaymentType.new
        request.transactionRequest.profile.customerProfileId = customer[:id]
        request.transactionRequest.profile.paymentProfile = ::AuthorizeNet::API::PaymentProfile.new(customer[:payment_profiles][0][:id])

        request.transactionRequest.transactionType = ::AuthorizeNet::API::TransactionTypeEnum::AuthOnlyTransaction
        request.transactionRequest.order = ::AuthorizeNet::API::OrderType.new(order[:order_id])

        response = client.create_transaction(request)
        transaction_id = response.transactionResponse.transId

        { authorization: transaction_id } if transaction_id.present?
      end
    end

    ##
    # Capture
    #
    # Captures a previously authoried transaction
    def capture(amount, transaction_id, _)
      handle_response do
        request = ::AuthorizeNet::API::CreateTransactionRequest.new

        request.transactionRequest = ::AuthorizeNet::API::TransactionRequestType.new
        request.transactionRequest.amount = amount / 100.0
        request.transactionRequest.refTransId = transaction_id
        request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::PriorAuthCaptureTransaction

        response = client.create_transaction(request)

        response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
      end
    end

    ##
    # Credit
    #
    # Issues a credit to customer for amount
    def credit(amount, source, _, _)
      handle_response do
        customer = get_customer(source.customer_id)
        return false if customer.nil?

        request = ::AuthorizeNet::API::CreateTransactionRequest.new

        request.transactionRequest = ::AuthorizeNet::API::TransactionRequestType.new
        request.transactionRequest.amount = amount / 100.0

        request.transactionRequest.profile = ::AuthorizeNet::API::CustomerProfilePaymentType.new
        request.transactionRequest.profile.customerProfileId = customer[:id]
        request.transactionRequest.profile.paymentProfile = ::AuthorizeNet::API::PaymentProfile.new(customer[:payment_profiles][0][:id])

        # request.transactionRequest.refTransId = transaction_id
        request.transactionRequest.transactionType = ::AuthorizeNet::API::TransactionTypeEnum::RefundTransaction

        response = client.create_transaction(request)

        response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
      end
    end

    ##
    # Void
    #
    # Voids a previously authed transaction
    def void(transaction_id, _, _)
      handle_response do
        request = ::AuthorizeNet::API::CreateTransactionRequest.new

        request.transactionRequest =  ::AuthorizeNet::API::TransactionRequestType.new
        request.transactionRequest.refTransId = transaction_id
        request.transactionRequest.transactionType = ::AuthorizeNet::API::TransactionTypeEnum::VoidTransaction

        response = client.create_transaction(request)

        response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
      end
    end
  end
end
