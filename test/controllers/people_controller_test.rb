require "test_helper"
class PeopleControllerTest < ActionDispatch::IntegrationTest

  test "can see people" do
    sign_in :sabine
    get people_url(params:{department_id: MANDATSVERWALTUNG})
    assert_response :success
  end

  test "cannot see people" do
    sign_in :tim
    get people_url(params:{department_id:MANDATSVERWALTUNG})
    assert_response :forbidden
  end

  test "can see public person listing" do
    sign_in :tim
    get public_people_url
    assert_response :success
  end



  ## index

  test 'member can index own persons' do
    sign_in :leif
    get people_url(params:{department_id:FINANZEN})
  end

  test 'member cannot index other departments persons' do
    sign_in :sonja
    get people_url(params:{department_id:SCHULUNGEN})
  end

  test 'member of Mandatsverwaltung sees persons' do
    sign_in :sabine
    get people_url(params:{department_id:MANDATSVERWALTUNG})
    assert_select '.person-info:nth-child(1) .person-name', 'Yasemin Person'
    assert_select '.person-info:nth-child(2) .person-name', 'Hossein Person'
    assert_select '.person-info:nth-child(3) .person-name', 'Wenjun Person'
  end

  test 'member of Netzwerk sees Netzwerk\'s own contact' do
    sign_in :leonie
    verify_see_contact NETZWERK, 'Dave Person'
  end

  test 'member of Schulungen sees Schulungen\'s own contact' do
    sign_in :sonja
    verify_see_contact SCHULUNGEN, 'Ruby Person'
  end

  test 'member of Öffentlicheit sees Öffentlichkeits\'s own contact' do
    sign_in :tammy
    verify_see_contact OEFFENTLICHKEIT, 'Lauren Person'
  end


  test 'member of Mandatsverwaltung should not see Netzwerk\'s contact' do
    sign_in :sabine
    get people_url(params:{department_id: NETZWERK})
    assert_response :forbidden
  end



  ## show

  test 'member of Netzwerk should be able to show Netzwerk\'s own contact' do
    sign_in :leonie
    get person_url(persons(:netzwerk_ressort_contact).id)
    assert_response :success
  end

  test 'member of Netzwerk should be able to show Schulungen\'s contact' do
    sign_in :leonie
    get person_url(persons(:schulungen_ressort_contact).id)
    assert_response :forbidden
  end

  ## edit

  test 'cannot edit client' do
    sign_in :tim
    get edit_person_path(persons(:yasemin).id)
    assert_response :forbidden
  end

  test 'can edit client if assigned for mandate' do
    sign_in :tim
    assign_and_approve_mandate_for :tim
    get edit_person_path(persons(:yasemin).id)
    assert_response :ok
  end

  ## update

  test 'member of Netzwerk should be able to update Netzwerk\'s own contact' do
    sign_in :leonie
    patch person_url(persons(:netzwerk_ressort_contact).id,
                    params:{person:{first_name:'Heinz', last_name:'Person'}})
    verify_see_contact NETZWERK, 'Heinz Person'
  end

  test 'member of Netzwerk should be able to update Schulungen\'s contact' do
    sign_in :leonie
    patch person_url(persons(:schulungen_ressort_contact).id,
                     params:{person:{first_name:'Heinz', last_name: 'Person'}})
    sign_in :sonja
    verify_see_contact SCHULUNGEN, 'Ruby Person'
  end

  test 'role client cannot be made public' do
    sign_in :sabine
    patch person_url(persons(:hossein).id,
                     params:{person:{public:true}})
    with :svenja do
      get public_people_url
      assert_select '.person-info:nth-child(1) .person-name', false
    end
  end

  # # ## create

  test 'member of Netzwerk should be able to create Netzwerk\'s own contact' do
    sign_in :leonie
    create NETZWERK, :contact
    get people_url(params:{department_id:NETZWERK})
    assert_select '.person-info:nth-child(1) .person-name', 'b a'
  end

  test 'member of Mandatsverwaltung should be able to create a contact with role client' do
    sign_in :sabine
    create MANDATSVERWALTUNG, :client
    get people_url(params:{department_id:MANDATSVERWALTUNG})
    assert_select '.person-info:nth-child(1) .person-name', 'b a'
  end

  test 'role client should not be shown in public view' do
    sign_in :sabine
    create MANDATSVERWALTUNG, :client, true
    with :svenja do
      get public_people_url
      assert_select '.person-info:nth-child(1) .person-name', false
    end
  end

  test 'member of Mandatsverwaltung should not be able to create a contact' do
    sign_in :sabine
    create MANDATSVERWALTUNG
    get people_url(params:{department_id:MANDATSVERWALTUNG})
    assert_select '.person-info:nth-child(1) .person-name', 'Yasemin Person'
  end

  test 'member of Schulungen should be able to create a public contact' do
    sign_in :sonja
    create SCHULUNGEN, :contact, true
    with :svenja do
      get public_people_url
      assert_select '.person-name', 'b a'
    end
  end

  private

  def create(department_id,role = nil, public = false)
    person = {
        last_name:'a',
        first_name: 'b' ,
        email:'a@b.com', role: role,
        department_id: department_id}
    person[:role] = role if role
    person[:public] = true if public

    post people_url(params: {person: person} )
  end
end