class MailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(h)
    h = JSON.load(h)
    ApplicationMailer.info(h['m_id'], h['email_subject'], h['email_body']).deliver
  end
end