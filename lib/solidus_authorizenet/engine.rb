# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'


module SolidusAuthorizenet
  class Engine < ::Rails::Engine
    include SolidusSupport::EngineExtensions
    isolate_namespace ::Spree

    engine_name 'solidus_authorizenet'

    initializer 'spree.payment_method.add_stripe_credit_card', after: 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << 'Spree::PaymentMethod::AuthorizeNetAcceptJS'
      ::Spree::PermittedAttributes.source_attributes.concat [:data_value, :data_descriptor]
    end

  end
end
