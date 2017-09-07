class AddMandateToConversations < ActiveRecord::Migration[5.0]
  def change
  	add_column :conversations, :mandate_id, :integer
  end
end
