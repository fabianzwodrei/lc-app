class UnreadConversationsWorker
  include Sidekiq::Worker

  def perform(*args)
    members = Member.where(subscribed_unread_conversations_email: true)
    members.each{ |m| UnreadConversationsMailWorker.perform_async(m.id) }
  end
end