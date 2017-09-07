class AddDepartmentIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :department_id, :integer
  end
end
