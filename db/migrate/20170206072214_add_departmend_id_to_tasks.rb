class AddDepartmendIdToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :department_id, :integer
  end
end
