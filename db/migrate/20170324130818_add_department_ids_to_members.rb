class AddDepartmentIdsToMembers < ActiveRecord::Migration[5.0]
  	def change
	  add_column :members, :departments, :integer, array: true, default: []
	end
end
