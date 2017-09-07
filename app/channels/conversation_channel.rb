# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ConversationChannel < ApplicationCable::Channel
  def subscribed
  	# TODO authentication for subscribtion of conversation
  	# +for private conversation
  	# +for exclusive department-conversations
  	# +for multi-department-conversations
    stream_from "conversation_channel_#{params[:conversation_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
