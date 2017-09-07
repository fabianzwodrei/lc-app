class RenameCoversationIdInDepartments < ActiveRecord::Migration[5.0]
  def change
  	rename_column :departments, :conversation_id, :internal_conversation_id
  end
end
