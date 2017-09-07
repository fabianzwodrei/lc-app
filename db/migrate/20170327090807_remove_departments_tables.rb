class RemoveDepartmentsTables < ActiveRecord::Migration[5.0]
  def change
  	drop_table :departments
  	drop_table :departments_members
  end
end
