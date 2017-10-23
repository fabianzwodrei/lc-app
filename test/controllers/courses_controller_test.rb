require "test_helper"
class CoursesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sonja
  end

  ## index

  test "can see courses" do
    get courses_url
    assert_response :success
  end

  test "cannot see courses" do
    sign_in :tina
    get courses_url
    assert_response :forbidden
  end



  ## update

  test "can update course data" do
    change_and_compare
  end

  test "cannot update course data" do
    sign_in :tina
    change_and_compare false
  end

  ## create

  test "can create course" do
    create
    get edit_course_url(Course.last)
    assert_select '#course_title[value=?]', SECOND_COURSE_TITLE
  end

  test "cannot create course" do
    sign_in :tina
    create
    assert_response :forbidden
  end

  # destroy
  test "can not destroy empty course that has messages" do
    with :svenja do
      attend :course_1
      post conversation_messages_url(conversations(:course_1_conversation).id),
         params: { message: {text: "bla bla" }}
      unattend :course_1
    end
    
    delete "/courses/#{courses(:course_1).id}"
    assert_response :precondition_failed
  end

  test "can not destroy course that has members left" do
    with :svenja do
      attend :course_1
    end
    
    delete "/courses/#{courses(:course_1).id}"
    assert_response :precondition_failed
  end


  test 'do see attend button' do
    sign_in :svenja
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .attend_button'
    assert_select '#course_1 .unattend_button', false
  end

  test 'do see attend button as member of Schulungen' do
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .attend_button'
    assert_select '#course_1 .unattend_button', false
  end


  test 'do see unattend button' do
    sign_in :svenja
    attend :course_1
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .unattend_button'
    assert_select '#course_1 .attend_button', false
  end

  test 'do not see attend button if course full' do
    attend :course_limited
    sign_in :svenja
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_2 .attend_button', false
    assert_select '#course_2 .unattend_button', false
  end

  test 'do not see attend/unattend buttons if course passed' do
    with :svenja do
      attend :course_1
    end
    patch award_attendance_path(@new_attendance_id)
    sign_in :svenja
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .attend_button', false
    assert_select '#course_1 .unattend_button', false
  end

  test 'do see full notice if course full' do
    attend :course_limited
    sign_in :svenja
    get event_url(courses(:course_limited).id) + ".htmlp"
    assert_select '#course_2 .full_notice'
  end

  test 'do not see full notice if course not full' do
    sign_in :svenja
    get event_url(courses(:course_limited).id) + ".htmlp"
    assert_select '#course_2 .full_notice', false
  end

  test 'do see passed notice' do
    with :svenja do
      attend(:course_1)
    end
    patch award_attendance_path(@new_attendance_id)
    sign_in :svenja
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .passed_notice'
  end

  test 'do see permitted notice' do
    sign_in :svenja
    attend(:course_1)
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .permitted_notice'
  end

  test 'do see waiting for permission notice' do
    sign_in :svenja
    attend(:course_limited_and_permission_required)
    get event_url(courses(:course_limited_and_permission_required).id) + ".htmlp"
    assert_select '#course_3 .waiting_for_permission_notice'
  end

  test 'do not see see any notices' do
    sign_in :svenja
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '#course_1 .passed_notice', false
    assert_select '#course_1 .permitted_notice', false
    assert_select '#course_1 .waiting_for_permission_notice', false
  end

  ## index

  test 'do see pencil as member of Schulungen' do
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '.pencil'
  end

  test 'do not see pencil as regular member' do
    sign_in :svenja
    get event_url(courses(:course_1).id) + ".htmlp"
    assert_select '.pencil', false
  end

  test 'do see open permission requests notice' do
    with :svenja do
      attend(:course_limited_and_permission_required)
    end
    get courses_url
    assert_select '#course_3 .open_permission_requests_notice'
  end

  test 'do not see open permission requests notice - when noone applied' do
    get courses_url
    assert_select '#course_3 .open_permission_requests_notice', false
  end

  test 'do not see open permission requests notice - when course open' do
    with :svenja do
      attend(:course_1)
    end
    get courses_url
    assert_select '#course_1 .open_permission_requests_notice', false
  end

  test 'do not see open permission requests notice - when permission granted' do
    with :svenja do
      attend(:course_limited_and_permission_required)
    end
    patch permit_attendance_path(@new_attendance_id)
    get courses_url
    assert_select '#course_3 .open_permission_requests_notice', false
  end

  test 'can see add_attendee part' do
    get edit_course_url(courses(:course_1))
    assert_select add_attendee_selector, true
  end

  ## add_member

  test 'can add member as member of Schulungen' do
    post add_member_to_event_url(id:courses(:course_1).id,member_id:members(:tim).id)
    get edit_course_url(courses(:course_1))
    assert_select first_attendee, members(:tim).full_name
  end

  test 'cannot add member as regular member' do
    with :tim do
      post add_member_to_event_url(id:courses(:course_1).id,member_id:members(:tim).id)
      assert_response :forbidden
    end
  end

  ## remove member

  test 'can remove member as member of Schulungen' do
    post add_member_to_event_url(id:courses(:course_1).id,member_id:members(:tim).id)
    post remove_member_from_event_url(id:courses(:course_1).id,member_id:members(:tim).id)
    get edit_course_url(courses(:course_1))
    assert_select first_attendee, false
  end

  test 'cannot remove member as regular member' do
    post add_member_to_event_url(id:courses(:course_1).id,member_id:members(:tim).id)
    with :tim do
      post remove_member_from_event_url(id:courses(:course_1).id,member_id:members(:tim).id)
    end
    get edit_course_url(courses(:course_1))
    assert_select first_attendee, members(:tim).full_name
  end

  test 'cannot remove member if course awarded' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_1
    end
    patch permit_attendance_path(attendance_id)
    patch award_attendance_path(attendance_id)

    post remove_member_from_event_url(id:courses(:course_1).id,member_id:members(:svenja).id)
    get edit_course_url(courses(:course_1))
    assert_select first_attendee, members(:svenja).full_name
  end

  private

  SECOND_COURSE_TITLE = "second one"

  def add_attendee_selector
    ".attendees .add_attendee"
  end

  def first_attendee
    ".attendee_full_name:first"
  end

  def create
    post courses_url,
         params: { course: { title: SECOND_COURSE_TITLE, module: 'module-1-lecture', dates_string: DateTime.now.strftime('%d.%m.%Y - %H:%M').to_s, where: 't' }}
  end

  def change_and_compare(expect_changed = true)
    put course_url(courses(:course_1).id),
        params: { course: { title: "new", dates_string: '2017-01-01', where: 't' }}

    with :sonja do
      expected = 'new'
      expected = courses(:course_1).title unless expect_changed
      get edit_course_url(courses(:course_1).id)
      assert_select '#course_title[value=?]', expected
    end
  end

  def attend(course)
    patch attend_event_path(courses(course))
    @new_attendance_id = Attendance.last.id
  end
end