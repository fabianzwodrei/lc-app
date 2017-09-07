class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAIL_ADDR']
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

end
