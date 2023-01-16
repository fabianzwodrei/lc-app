class UnreadConversationsMailWorker
	include Sidekiq::Worker
	include Sidekiq::Throttled::Worker
	sidekiq_options retry: 2 
	
	sidekiq_throttle({
		:concurrency => { :limit => 1 },
		:threshold => { :limit => 50, :period => 1.hour }
	})

	def perform(member_id)
		ApplicationMailer.unread_conversations(member_id).deliver 
	end
end