class RenameProtocolIdToConversationId < ActiveRecord::Migration[5.0]
  def change
    rename_column :departments, :protocol_id, :conversation_id
    rename_column :messages, :protocol_id, :conversation_id
  end
end
