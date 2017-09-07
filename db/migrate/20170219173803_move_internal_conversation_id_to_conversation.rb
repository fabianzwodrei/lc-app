class MoveInternalConversationIdToConversation < ActiveRecord::Migration[5.0]
  def change
  	remove_column :departments, :internal_conversation_id
  	add_column :conversations, :department_id, :integer
  end
end
