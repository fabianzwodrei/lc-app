require "test_helper"
class DocumentsControllerTest < ActionDispatch::IntegrationTest
	
	setup do
    	sign_in :tim
  	end

  	test 'can create document in Mandatsverwaltung Bib' do
  		sign_in :sabine
  		image = fixture_file_upload('lc-logo.jpeg')
  		post "/bibliographies/" + bibliographies(:mandatsbib).id.to_s + "/documents", params: { document: { title: "Testdokument", attachment: image } }
		assert_response :redirect
    	assert_equal flash[:notice], "Dokument wurde erfolgreich hinzugefügt."
  	end
end