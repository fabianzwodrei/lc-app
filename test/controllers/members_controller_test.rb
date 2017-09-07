require "test_helper"
class MembersControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :tina
  end

  test "adding member" do
    email_adrre = "tom@tom.com"
    response = add_member email_adrre
    get members_url
    assert_select "#member-#{response['id']} .member_full_name", "Firstname Lastname"
	end

	test "failing to access members index if not logged in" do
    sign_in :anonymous
    get members_url
    assert_response :redirect
  end

  test "failing to access members url (form) if not member of internal organisation" do
    sign_in :tim
    get edit_member_url(1)
    assert_response :forbidden
  end


  ## update

  test 'member of interne orga can update members profile' do
    update_and_compare :tim
  end

  test 'member can update its own profile' do
    sign_in :tim
    update_and_compare :tim
  end

  test 'member cannot update another members profile' do
    sign_in :tim
    update_and_compare :sabine, false
  end

  test 'regular member cannot change its departments' do
    sign_in :tim
    update_departments_and_compare :tim, ''
  end

  test 'regular member cannot change another members departments' do
    sign_in :tim
    update_departments_and_compare :sabine, 'Mandatsverwaltung'
  end

  # update of rights is only possible via update rights
  test 'member of interne orga cannot change another members departments via update' do
    sign_in :tina
    update_departments_and_compare :sabine, 'Mandatsverwaltung'
  end

  # show

  test 'members can show their profile' do
    verify_can_see_own_profile :sabine
    verify_can_see_own_profile :tim
    verify_can_see_own_profile :sonja
    verify_can_see_own_profile :svenja
    verify_can_see_own_profile :tina
  end

  test 'see qualifications' do
    sign_in :tim
    get member_url(members(:tim).id)
    assert_select '#qualifications tr:nth-child(2) .title', 'Tim2'
    assert_select '#qualifications tr:nth-child(2) .qualification_validity', "Gültig bis #{(Date.yesterday+365).strftime('%d.%m.%Y')}"
  end


  test 'member of sprechstunde can see qualifications' do
    sign_in :martha
    get qualification_member_url(members(:tim).id) + '.htmlp'
    assert_response :ok
  end

  test 'regular member cannot see qualifications' do
    sign_in :tim
    get qualification_member_url(members(:tim).id) + '.htmlp'
    assert_response :forbidden
  end

  test 'member of Mandatsverwaltung can see qualification for member' do
    sign_in :sabine
    get qualification_member_url(members(:tim).id) + '.htmlp'
    assert_response :ok 
  end

  test 'member of Sprechstunde can see qualification for member' do
    sign_in :martha
    get qualification_member_url(members(:tim).id) + '.htmlp'
    assert_response :ok 
  end

  test 'member of Finanzen can not see qualification for member' do
    sign_in :leif
    get qualification_member_url(members(:tim).id) + '.htmlp'
    assert_response :forbidden
  end

  ## index

  test 'member of Mandatsverwaltung can member annotations-listing' do
    sign_in :sabine
    get annotations_members_url
    assert_response :ok
  end

  test 'member of Sprechstunde can see members qualifications-listing but not annotations-listing' do
    sign_in :martha
    get qualifications_members_url
    assert_response :ok

    get annotations_members_url
    assert_response :forbidden
  end

  test 'member of Finanzen can not see member annotations-listing or qualifications-listing' do
    sign_in :leif
    get annotations_members_url
    assert_response :forbidden

    get qualifications_members_url
    assert_response :forbidden
  end

  ## rights_index

  test 'can see it' do
    sign_in :fatima
    get members_rights_url
    assert_response :ok
  end

  test 'cannot see it' do
    get members_rights_url
    assert_response :forbidden
  end

  ## rights_edit

  test 'can see rights_edit' do
    sign_in :fatima
    get edit_member_right_url(1)
    assert_response :ok
  end

  test 'cannot see rights_edit' do
    get edit_member_right_url(1)
    assert_response :forbidden
  end

  test 'forbid to edit ones own right' do
    sign_in :fatima
    get edit_member_right_url(members(:fatima).id)
    assert_response :forbidden
  end

  test 'but do not forbid to edit ones own right for members of Vorstand' do
    sign_in :olga
    get edit_member_right_url(members(:olga).id)
    assert_response :ok
  end

  test 'forbid to edit anothers members rights as member of Vorstand however' do
    sign_in :olga
    get edit_member_right_url(1)
    assert_response :forbidden
  end


  ## rights_update

  test 'can update rights' do
    sign_in :fatima
    patch update_member_right_url(1), {params: {member: {departments:[1]}}}
    assert_response :redirect
    assert_equal flash[:notice], "Die Berechtigungen wurden erfolgreicht aktualisiert."
  end

  test 'cannot update rights' do
    patch update_member_right_url(1), {params: {member: {departments:[1]}}}
    assert_response :forbidden
  end

  test "cannot update one's one rights" do
    patch update_member_right_url(members(:fatima).id), {params: {member: {departments:[1]}}}
    assert_response :forbidden
  end

  test "but do can update one's one rights if member of Vorstand" do
    sign_in :olga
    patch update_member_right_url(members(:olga).id), {params: {member: {departments:[1]}}}
    assert_response :redirect
  end

  test "cannot update another members rights as member of Vorstand however" do
    sign_in :olga
    patch update_member_right_url(1, {params: {member: {departments:[1]}}})
    assert_response :forbidden
  end


  ## departments

  test 'can see departments page' do
    sign_in :olga
    get departments_members_path
    assert_select '#department-2 li:first-child .email', 'leonie@netzwerk.com'
  end

  test 'cannot see departments page' do
    sign_in :fatima
    get departments_members_path
    assert_response :forbidden
  end

  private

  def verify_can_see_own_profile(member)
    with member do
      get member_url(members(member).id)
      assert_response :ok
    end
  end

  def update_and_compare(member_to_update,expect_changed=true)
    patch member_url(members(member_to_update).id),
          params: { member: { first_name: 'new_name' }, format: :json}

    with :tina do
      get edit_member_url(members(member_to_update).id)

      expected_name = member_to_update.to_s
      expected_name = 'new_name' if expect_changed
      assert_select "#member_first_name[value=?]", expected_name
    end
  end

  def update_departments_and_compare(member_to_update,expected)
    patch member_url(members(member_to_update).id),
          params: { member: { departments: [ORGANISATION] }, format: :json}

    with :tina do
      get members_url
      assert_select "#member-#{members(member_to_update).id} .departments-list", expected
    end
  end
end				