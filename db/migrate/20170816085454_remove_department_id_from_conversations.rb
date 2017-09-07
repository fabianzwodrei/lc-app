class RemoveDepartmentIdFromConversations < ActiveRecord::Migration[5.0]
  def change
  	remove_column :conversations, :department_id
  end
end
