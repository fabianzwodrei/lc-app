class UnreadConversationsMailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(member_id)
    ApplicationMailer.unread_conversations(member_id).deliver 
  end
end