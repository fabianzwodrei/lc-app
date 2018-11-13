class ApplicationMailer < ActionMailer::Base
  # default from: ENV['MAIL_ADDR']
  default from: "noreply@zwodrei.com"
  layout 'mailer'

  def info (m_id, subject, body)
  	@member = Member.find(m_id)
  	if @member.locked_at == nil
  		@email = @member.email
  		@body = body
  		@subject = subject
  		mail(to: @email, subject: subject)
  	end
  end

  def unread_conversations (member_id)
    @member = Member.find(member_id)
    if @member.locked_at == nil
      @conversations = Conversation.unread @member
      return if @conversations.empty?
      mail(to: @member.email, subject: "Nachrichten in Law Clinic App")
    end
  end
end