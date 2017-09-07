class AddPrivacyToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :did_confirm_privacy_clause, :boolean, default: false
  end
end
