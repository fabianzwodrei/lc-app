class RenameProtocolToConversation < ActiveRecord::Migration[5.0]
  def change
    rename_table :protocols, :conversations
  end
end
