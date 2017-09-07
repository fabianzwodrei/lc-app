require "test_helper"
class DocumentsControllerTest < ActionDispatch::IntegrationTest
	
	setup do
    	sign_in :tim
  	end

  	# todo
  	# test for get_attachment-request on doc without attachment-file
end