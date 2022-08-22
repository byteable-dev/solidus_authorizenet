# frozen_string_literal: true

module Spree
  class PaymentMethod
    ##
    # AuthorizeNet Payment Method
    #
    # This is the actual payment method that is available to the user. It is set up
    # in the backend by an admin. It needs credentials from AuthorizieNet to work.
    #
    # When the payment method is used in the store it creates a source
    # that is provided to the gateway.
    class AuthorizeNetAcceptJs < Spree::PaymentMethod
      # If payment method is in test mode or not (using sandbox)
      preference :test_mode, :boolean

      # The api login id to use with authorize net api
      preference :api_login_id, :string

      # The api transaction key to use with authorize net api
      preference :api_transaction_key, :string

      # The api public key to use with authorize net accept.js form
      preference :api_public_key, :string

      # The partial name to use for payment form when user is checking out
      def partial_name
        'authorize_net'
      end

      # The class to use as payment source. It stores information about the
      # acceptjs validation and the authornize net customer profile id
      def payment_source_class
        ::SolidusAuthorizenet::PaymentSource
      end

      # The gateway class to use when communicating with AuthorizeNet API, for exaple
      # when capturing a payment or refunding a transaction
      def gateway_class
        ::SolidusAuthorizenet::Gateway
      end

      # This payment method supports payment profiles. This means that when a payment
      # is made via acceptjs then we createa  customer within AuthorizeNet. This customer
      # is then used for all later communication with the API.
      def payment_profiles_supported?
        true
      end

      ##
      # Create Profile
      #
      # Is called after the acceptjs validation is complete. Should create
      # the customer in AuthorizeNet. If a customer is already found
      # on the payment source we just bail out and reuse that.
      def create_profile(payment)
        return if payment.source.customer_id.present?

        customer_id = gateway.create_customer(payment)

        Rails.logger.info "AuthorizeNetAcceptJs: create_profile: customer_id: #{customer_id}"

        payment.source.update(customer_id: customer_id)
      rescue ::Spree::Core::GatewayError => e
        Rails.logger.fatal e
        raise e
      end

      ##
      # Returns all reusable payment sources for the provided
      # order.
      def reusable_sources(order)
        if order.completed?
          reusable_sources_by_order(order)
        elsif order.user_id
          order.user.wallet.wallet_payment_sources.map(&:payment_source).select(&:reusable?)
        else
          []
        end
      end

      ##
      # Finds all reusable payment sources for the provided order.
      def reusable_sources_by_order(order)
        source_ids = order.payments.where(payment_method_id: id).pluck(:source_id).uniq
        payment_source_class.where(id: source_ids).select(&:reusable?)
      end

      ##
      # Tries to void a previously authorized payment.
      def try_void(payment)
        gateway.void(payment.response_code, nil, nil)
      end
    end
  end
end
