# frozen_string_literal: true

module SolidusAuthorizenet
  ##
  # AuthorizeNet Payment Source
  #
  # This source is keeping information about an actual initial payment and
  # then later updated with an authorize net customer id when payment was
  # approved.
  #
  # It works together with AuthorizeNet's accept.js solution, so initiatlly
  # it is seeded with a data_value and data_descriptor. This is used to
  # create a customer and a payment profile within Authorize Net.
  #
  # Whent he payment profile is created correctly this source is updated
  # with the customer id from AuthorizeNet.
  #
  # This customer id is then used as payment profile within AuthorizeNet
  # for authorize, capturing, voiding and refunding.
  class PaymentSource < ::Spree::PaymentSource
    # The table name of the sources
    self.table_name = 'solidus_authorizenet_payment_sources'

    # A source can belong to a user - this means that this source is used
    # in other payments, for example for subscriptions etc.
    belongs_to :user, class_name: ::Spree::UserClassHandle.new, optional: true

    # It must have a data_value and data_descriptor since this is initiatlly
    # used to create the customer after the credit card is validated
    # by accept.js
    validates(:data_value, presence: true)
    validates(:data_descriptor, presence: true)
    validates(:last4, presence: true)
    validates(:expire_month, presence: true)
    validates(:expire_year, presence: true)

    attr_accessor(:address_attributes)

    # Delegate customer id to our own customer id
    def gateway_customer_profile_id
      customer_id
    end

    # Means that this source can be reused for other payments
    def reusable?
      true
    end

    # If payment can be credited. Can't credit until at least 2 day is went by.
    # Should mean the payment is settled
    def can_credit?(payment)
      return false if payment.completed? && payment.created_at > 2.day.ago

      super
    end

    # If payment can be voided. Can't void after 2 days because
    # that should mean the payment must be settled.
    def can_void?(payment)
      return false if payment.completed? && payment.created_at < 1.day.ago

      super
    end

    def display_name
      "Card ending in #{last4} that expires #{expire_month}/#{expire_year}"
    end
  end
end
