require "test_helper"
class MessagesControllerTest < ActionDispatch::IntegrationTest
	
	setup do
    	sign_in :tim
  	end

  	test "assigned member can create message on protocol" do
		apply_for_mandate
		with :sabine do
			approve_latest_assignment
		end
		post_protocol_message
		visit_mandate_path
        assert_select @@first_msg, @msg_text
  	end

  	test "unassigned member cannot create message on protocol" do
		apply_for_mandate
		post_protocol_message
		assert_response :forbidden
  	end
  	
  	#todo
	# test " can create message with attachment" do
	# end

  	#todo
	# test " unassigned member cannot get attachment download for message" do
	# end

	#todo
	# test for get_attachment-request on msg without attachment-file

	private 
		@@first_msg = '.message:first-child .message-content'
	  	@@msg_text = 'I Like Them Pizzas'

	  	def post_protocol_message
	  		post conversation_messages_url(conversations(:mandate1_protocol_conversation).id),
    	     params: { message: {text: @@msg_text}}
	  	end

end