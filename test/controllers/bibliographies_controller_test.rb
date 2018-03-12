require "test_helper"
class BibliographiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sabine
  end

  test "can see bibliographies listing" do
    get bibliographies_url, params: { department_id: MANDATSVERWALTUNG }
    assert_response :success
  end

  test "cannot see bibliographies listing of department" do
    sign_in :tina
    get bibliographies_url, params: { department_id: MANDATSVERWALTUNG }
    assert_response :forbidden
  end

  test "can create public bibliography" do
    create "Bib 123", department_id: nil
    get bibliographies_url
    find_bib_link "Bib 123"
  end

  test "can create department bibliography" do
    create "Mandatsbib", MANDATSVERWALTUNG
   	get bibliographies_url, params: { department_id: MANDATSVERWALTUNG }
    find_bib_link "Mandatsbib"
  end

  test "cannot create public bibliography" do
    sign_in :svenja
    create "svenjas", department_id: nil
    get bibliographies_url
    find_bib_link "svenjas", 0
  end

  test "cannot create foreign department bibliography" do
  	sign_in :tina do
    	create "Tinas Mandatsbib", MANDATSVERWALTUNG
    end
   	get bibliographies_url, params: { department_id: MANDATSVERWALTUNG }
    find_bib_link "Tinas Mandatsbib", 0
  end

  private
  	def create title, department_id
	    post bibliographies_url,
	         params: { bibliography: { title: title, description: "lorem ipsum", department_id: department_id}}
	end

	def find_bib_link title, count = 1
		assert_select "a", { count: count, text: title}
	end
end