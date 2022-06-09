class CreateSolidusAuthorizenetPaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_authorizenet_payment_sources do |t|
      t.string :data_value
      t.string :data_descriptor
      t.integer :user_id
      t.references :payment_method, null: false, foreign_key: { to_table: :spree_payment_methods }

      t.timestamps
    end
    add_index :solidus_authorizenet_payment_sources, :user_id
  end
end
