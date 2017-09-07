require "test_helper"
class ConstultationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :martha
  end

  ## index

  test "can see consultations" do
    get consultations_url
    assert_response :success
  end

  test "cannot see consultations" do
    sign_in :tina
    get consultations_url
    assert_response :forbidden
  end

  ## create

  test 'can create consultation' do
    create
    get consultations_url
    assert flash[:notice] == 'Sprechstunde wurde erfolgreich angelegt.'
    assert_select "#consultation_#{@new_id}_heading .consultation_title", 'one'
  end

  test 'cannot create consultation' do
    with :tim do
      create
      assert_response :forbidden
    end
    get consultations_url
    assert_select "#consultation_#{@new_id}_heading .consultation_title", false
  end

  test 'cannot create a a consultation with illegal time' do
    post consultations_url,
         params: { consultation: { title: 'one', when: 'w', where: 't', dates: 'a:b' }}
    get consultations_url
    assert_select ".accordion .card", false
  end

  ## add_member

  test 'can add member as member of Sprechstunde' do
    create
    post add_member_to_event_url(id:@new_id,member_id:members(:tim).id)
    get consultations_url
    assert_select first_attendee, members(:tim).full_name
  end

  test 'cannot add member as regular member' do
    create
    with :tim do
      post add_member_to_event_url(id:@new_id,member_id:members(:tim).id)
    end
    get consultations_url
    assert_select first_attendee, false
  end

  ## remove_member

  test 'can remove member as member of Sprechstunde' do
    create
    post add_member_to_event_url(id:@new_id,member_id:members(:tim).id)
    post remove_member_from_event_url(id:@new_id,member_id:members(:tim).id)
    get consultations_url
    assert_select first_attendee, false
  end

  test 'cannot remove member as regular member' do
    create
    post add_member_to_event_url(id:@new_id,member_id:members(:tim).id)
    with :tim do
      post remove_member_from_event_url(id:@new_id,member_id:members(:tim).id)
      assert_response :forbidden
    end
  end

  private

  def first_attendee
    "#consultation_#{@new_id} .attendees .row:first-child .attendee_full_name"
  end

  def create
    post consultations_url,
         params: { consultation: { title: 'one', when: 'w', where: 't', dates_string: DateTime.now.strftime('%d.%m.%Y - %H:%M').to_s }}
    @new_id = Event.last.id
  end
end