class AddAdditionalDepartmentIdsToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :additional_departments_ids, :integer, array: true
  end
end
