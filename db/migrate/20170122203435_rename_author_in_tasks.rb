class RenameAuthorInTasks < ActiveRecord::Migration[5.0]
  def change
  	rename_column :tasks, :author_id, :assigned_member_id
  end
end
