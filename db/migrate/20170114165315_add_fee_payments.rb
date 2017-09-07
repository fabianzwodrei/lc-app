class AddFeePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :fee_payments do |t|
      t.text :payment_history_notes
      t.boolean :paid
      t.boolean :direct_debit_allowed
      t.text :account_details
    end
  end
end
