class AddLast4AndExpirationToSolidusAuthorizenetPaymentSources < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_authorizenet_payment_sources, :last4, :string
    add_column :solidus_authorizenet_payment_sources, :expire_month, :integer
    add_column :solidus_authorizenet_payment_sources, :expire_year, :integer
  end
end
