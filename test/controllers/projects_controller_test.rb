require "test_helper"
class ProjectsControllerTest < ActionDispatch::IntegrationTest
	setup do
    sign_in :sabine
  end

  test "can see project on department homepage" do
    get "/departments/" + MANDATSVERWALTUNG.to_s
    assert_response :success
    assert_select ".projects_department_only a##{projects(:mandatsverwaltung_project).id}"
  end

  test "can see project shared with other departments on department homepage" do
    get "/departments/" + MANDATSVERWALTUNG.to_s
    assert_response :success
    assert_select ".projects_department_shared a##{projects(:mandatsverwaltung_with_sprechstunde_project).id}"
  end

  test "can see archived project shared with other departments in archive" do
  	get '/projects/archived'
    assert_response :success
  	assert_select ".archived_department_projects a##{projects(:archived_mandatsverwaltung_with_sprechstunde_project).id}"
  end

 	test "regular member can see archived-projects site" do
 		with :tim do
	 		get '/projects/archived'
	    assert_response :success
	  end
 	end
 
 	test "tim not invited, wont be allowed to open project" do
  	with :tim do
	 		get "/projects/#{projects(:mandatsverwaltung_project).id}"
	    assert_response :forbidden
	  end
  end

  test "tim invited, will be allowed to post messages" do
  	post "/projects/#{projects(:mandatsverwaltung_project).id}/add_member", params: {member_id: members(:tim).id}
  	with :tim do
	 		get "/projects/#{projects(:mandatsverwaltung_project).id}"
	    assert_response :success
	    post "/conversations/#{conversations(:mandatsverwaltung_conversation).id}/messages", params: {message: {text: "something said here"}}
	    assert_response :ok
	 		get "/projects/#{projects(:mandatsverwaltung_project).id}"
	    assert_select '.message:first-child .message-content', 'something said here'
	  end
  end

  test "can create new project" do
  	post projects_url, params: {project: {title: "do things", departments: [0]}}
  	pnew = Project.last.id
  	get "/departments/" + MANDATSVERWALTUNG.to_s
    assert_response :success
    assert_select ".projects_department_only a##{pnew}", "do things"
  end

  test "can update project" do
  	patch "/projects/#{projects(:mandatsverwaltung_project).id}", params: {project: {title: "do do da"}}
  	get "/departments/" + MANDATSVERWALTUNG.to_s
    assert_response :success
    assert_select ".projects_department_only a##{projects(:mandatsverwaltung_project).id}", "do do da"
  end

end