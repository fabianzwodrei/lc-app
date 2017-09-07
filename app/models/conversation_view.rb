class ConversationView < ActiveRecord::Base
	

	belongs_to :conversation
	belongs_to :member

	def self.create_or_update_for conversation_id, member_id
		c = ConversationView.find_or_create_by(conversation_id: conversation_id, member_id: member_id)
		c.update(viewed_at: Time.now)
	end
end