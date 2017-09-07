class AddEventIdToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :event_id, :integer
  end
end
