class AddDepartmentIdToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :department_id, :integer
  end
end
