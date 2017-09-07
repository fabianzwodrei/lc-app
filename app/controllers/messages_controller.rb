class MessagesController < ApplicationController
	load_and_authorize_resource :conversation
  	load_and_authorize_resource :message, :through => :conversation


	def create
	    m = current_member.messages.create!(message_params)
	    if c = Conversation.find(params[:conversation_id])
	    	ConversationView.create_or_update_for c.id, current_member.id
	    end
	    head :ok, content_type: "text/html"
  	end

  	def get_attachment
	    head(:not_found) and return if (@message = Message.find(params[:message_id])).nil? or not @message.attachment.exists?
	    head(:bad_request) and return unless File.exist?(@message.attachment.path)
	      
		send_file_options = { filename: @message.attachment_file_name, type: @message.attachment_content_type }
	    send_file(@message.attachment.path, send_file_options)
	end

	def thread
		if params[:origin]
	      @origin = params[:origin]
	    end
		@parent_message = Message.find(params[:message_id])
		@conversation = @parent_message.conversation
		@messages = Message.where(parent_id: @parent_message.id)
	end

	private
		def message_params 
		    params.require(:message).permit(
		      :text, :attachment, :parent_id
		    ).merge(conversation_id: params[:conversation_id])
		 end
  	
end
