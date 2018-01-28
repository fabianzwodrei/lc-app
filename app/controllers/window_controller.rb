class WindowController < ApplicationController

  before_action :auth
  skip_before_action :authenticate_member!, only: [:home,:detail,:message]

  def home
  end

  def detail
    @msg_content = flash[:msg]['content'] if flash[:msg] && flash[:msg]['content']
    @access_code = params[:access_code]
    @mandate = Mandate.where("lower(code) LIKE '#{params[:access_code].downcase}%'").first
  end

  def message
    @mandate = Mandate.find_by_code (params[:access_code] + params[:confirmation_code])
    unless @mandate
      flash[:msg_content] = params[:message][:content]
      return redirect_back(notice: "Die Nachricht wurde nicht versendet, da der Bestätigungscode nicht korrekt ist.",
                           fallback_location: 'window')
    end
    @mandate.conversation.messages.push Message.create(text: params[:message][:content], attachment:params[:message][:attachment], member_id: -1)
    @mandate.save
    redirect_back(notice: "Die Nachricht wurde erfolgreicht übermittelt.",
                  fallback_location: 'window')
  end

  private

    def auth
      authorize! :interact_with, :window
    end
end