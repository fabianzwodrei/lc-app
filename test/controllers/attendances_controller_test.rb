require "test_helper"
class AttendancesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sonja
  end

  ## award / unaward

  test 'can award attendance' do
    attendance_id = nil
    with :svenja do
      attendance_id = attend :course_1
    end
    patch permit_attendance_path(attendance_id)
    patch award_attendance_path(attendance_id)
    verify_unaward_action_visible :course_1
  end

  test 'cannot award attendance' do
    with :svenja do
      attendance_id=attend :course_1
      patch award_attendance_path(attendance_id)
      assert_response :forbidden
    end
  end

  test 'can award and unaward attendance' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_1
    end
    patch permit_attendance_path(attendance_id)
    patch award_attendance_path(attendance_id)
    patch unaward_attendance_path(attendance_id)
    verify_award_action_visible :course_1
  end

  test 'cannot unaward attendance' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_1
    end
    patch award_attendance_path(attendance_id)
    with :svenja do
      patch unaward_attendance_path(attendance_id)
      assert_response :forbidden
    end
  end

  ## permit / unpermit

  test 'can permit attendance' do
    attendance_id = nil
    with :svenja do
      attendance_id = attend :course_limited
    end
    patch permit_attendance_path(attendance_id)
    assert_response :redirect
  end

  test 'cannot permit attendance' do
    with :svenja do
      attendance_id = attend :course_limited
      patch permit_attendance_path(attendance_id)
      assert_response :forbidden
    end
  end

  test 'can unpermit attendance' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_limited
    end
    patch permit_attendance_path(attendance_id)
    patch unpermit_attendance_path(attendance_id)
    assert_response :redirect
  end

  test 'cannot unpermit attendance' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_limited
    end
    patch permit_attendance_path(attendance_id)
    with :svenja do
      patch unpermit_attendance_path(attendance_id)
      assert_response :forbidden
    end
  end

  ## courses_controller#public_index

  test 'cannot see other attendees if do not attend' do
    with :svenja do
      attend :course_1
    end
    get event_url(courses(:course_1)) + ".htmlp"
    verify_see_no_attendance :course_1
  end

  test 'cannot see other attendees if do not permitted' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_permission_required
    end
    patch permit_attendance_path(attendance_id)
    attend :course_permission_required
    get event_url(courses(:course_permission_required)) + ".htmlp"
    verify_see_no_attendance :course_permission_required
  end

  test 'can see other attendees if attend' do
    with :svenja do
      attend :course_1
    end
    attend :course_1
    get event_url(courses(:course_1)) + ".htmlp"
    assert_select (member_of_course_fullname :course_1), members(:svenja).full_name
    assert_select (member_of_course_fullname :course_1, 2), members(:sonja).full_name
  end

  ## courses_controller#index

  test 'do see attendee' do
    with :svenja do
      attend :course_1
    end
    get edit_course_url(courses(:course_1))
    assert_select (member_of_course_fullname :course_1), members(:svenja).full_name
  end

  private

  def verify_award_action_visible(course)
    get edit_course_url(courses(course))
    assert_select member_of_course_selector(course,1)+' .course_award_action', true
  end

  def verify_unaward_action_visible(course)
    get edit_course_url(courses(course))
    assert_select member_of_course_selector(course,1)+' .course_unaward_action', true
  end
end