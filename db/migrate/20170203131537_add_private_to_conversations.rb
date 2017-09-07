class AddPrivateToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :private, :boolean
    add_column :conversations, :member1_id, :integer
    add_column :conversations, :member2_id, :integer
  end
end
