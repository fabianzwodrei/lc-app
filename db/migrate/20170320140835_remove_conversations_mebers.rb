class RemoveConversationsMebers < ActiveRecord::Migration[5.0]
  def change
  	drop_table :conversations_members
  end
end
