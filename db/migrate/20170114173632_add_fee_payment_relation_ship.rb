class AddFeePaymentRelationShip < ActiveRecord::Migration[5.0]
  def change
    add_column :fee_payments, :member_id, :integer
  end
end
