class RemoveCanEditFromDepartments < ActiveRecord::Migration[5.0]
  def change
  	remove_column :departments, :can_edit
  end
end
