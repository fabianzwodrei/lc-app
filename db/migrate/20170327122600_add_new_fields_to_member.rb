class AddNewFieldsToMember < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :languages, :string
  	add_column :members, :available, :boolean, default: true
  end
end
