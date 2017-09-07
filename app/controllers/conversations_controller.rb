class ConversationsController < ApplicationController

  load_and_authorize_resource
  before_action :set_conversation, only: [:show]

  def new
  end

  def create
    if @conversation.private and @conversation.member2_id
      if @old_conversation = Conversation.private_between(current_member.id, @conversation.member2_id).first
        redirect_to conversation_url(@old_conversation)+"#bottom"
      else
        if @conversation.save
          redirect_to @conversation
        end
      end
    end
  end

  def show
    if @conversation.mandate
      @title = "Mandatsprotokoll für Mandat ##{@conversation.mandate_id}"
    end
    if @conversation.event_id
      @title = "Kursforum '#{Event.find(@conversation.event_id).title}'"
    end
    if @conversation.project_id
      @title = "Projektchat '#{@conversation.project.title}'"
    end
    @title ||= "Privater Chat mit  #{@conversation.get_other_member(current_member).full_name}"

    @messages = @conversation.messages.parents_only.chat_order 

    ConversationView.create_or_update_for @conversation.id, current_member.id
  end

  def index
    @private_conversations = Conversation.privates(current_member)
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def conversation_params 
    params.require(:conversation).permit(
      :member1_id, :member2_id, :private
    )
  end

end