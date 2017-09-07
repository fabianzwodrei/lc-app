class AddFieldsToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :last_name, :string
    add_column :members, :entry_date, :date
  end
end
