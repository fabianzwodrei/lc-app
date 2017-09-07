class RemoveAdditionalDepartmentsFromEvents < ActiveRecord::Migration[5.0]
  def change
  	remove_column :events, :additional_departments_ids
  end
end
