class AddSubscribedUnreadConversationsToMembers < ActiveRecord::Migration[5.0]
  def change
  	add_column :members, :subscribed_unread_conversations_email, :boolean, default: false
  end
end
