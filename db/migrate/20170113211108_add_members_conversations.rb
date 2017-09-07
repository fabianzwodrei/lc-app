class AddMembersConversations < ActiveRecord::Migration[5.0]
  def change
    create_join_table :conversations, :members do |t|
    end
  end
end
