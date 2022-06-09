class AddCustomerIdToSolidusAuthorizenetPaymentSource < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_authorizenet_payment_sources, :customer_id, :bigint
  end
end
