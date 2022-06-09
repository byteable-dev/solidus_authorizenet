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

    attr_accessor(:address_attributes)

    # Means that this source can be reused for other payments
    def reusable?
      true
    end
  end
end
