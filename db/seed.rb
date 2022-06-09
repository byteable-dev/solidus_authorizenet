# frozen_string_literal: true

api_login_id = ENV['AUTHORIZENET_API_LOGIN_ID']
api_public_key = ENV['AUTHORIZENET_API_PUBLIC_KEY']
api_transaction_key = ENV['AUTHORIZENET_API_TRANSACTION_KEY']

if api_login_id.blank? || api_public_key.blank? || api_signature_key.blank?
  puts 'Missing either:'
  puts ' - AUTHORIZENET_API_LOGIN_ID'
  puts ' - AUTHORIZENET_API_PUBLIC_KEY or'
  puts ' - AUTHORIZENET_API_TRANSACTION_KEY'
  puts ''
  puts 'as environment variables.'
  return
end

authorizenet_payment_method = Spree::PaymentMethod::AuthorizeNetAcceptJS.new do |payment_method|
  payment_method.name = 'Credit Card'
  payment_method.preferred_api_login_id = api_login_id
  payment_method.preferred_api_public_key = api_public_key
  payment_method.preferred_api_transaction_key = api_transaction_key
end

if authorizenet_payment_method.save
  puts 'AuthorizeNet CreditCard Payment Method successfully created'
else
  puts 'There was some problems with creating AuthorizeNet Payment Method:'
  authorizenet_payment_method.errors.full_messages.each do |error|
    puts error
  end
end
