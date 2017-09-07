class AddsCanEditToDepartments < ActiveRecord::Migration[5.0]
  def change
  	add_column :departments, :can_edit, :text
  end
end
