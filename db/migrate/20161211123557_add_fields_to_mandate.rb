class AddFieldsToMandate < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :done, :boolean
    add_column :mandates, :description, :text
  end
end
