ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

 
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  @@current_member = nil

  def sign_in(member_name)
    sign_out if @@current_member != nil
    _sign_in member_name if member_name != :anonymous
    @@current_member = member_name
  end

  def sign_out
    delete destroy_member_session_url
  end

  def with(member_name)
    current_member = @@current_member
    sign_in member_name
    yield
    sign_in current_member
  end

  def add_member(email_address)
    post members_url, params: { member: { email: "#{email_address}", first_name: "Firstname", last_name: "Lastname", password: "jackewiehose2", password_confirmation: "jackewiehose2"}, format: :json }
    JSON.parse response.body
  end

  def apply_for_mandate
    patch mandate_apply_path mandates(:mandate_1).id
  end

  def unapply_for_mandate
    patch mandate_unapply_path mandates(:mandate_1).id
  end

  def approve_latest_assignment
    patch mandate_assignment_path(mandates(:mandate_1).id, mandates(:mandate_1).assignments.last.id)
  end

  def reject_assignment
    delete mandate_assignment_path mandates(:mandate_1).id, mandates(:mandate_1).assignments.last.id
  end

  def close_mandate
    patch mandate_url mandates(:mandate_1).id, params: { mandate: {status: "done"}}
  end

  def activate_mandate
    patch mandate_url mandates(:mandate_1).id, params: { mandate: {status: "active"}}
  end

  def visit_edit_mandate_path
    get edit_mandate_path mandates(:mandate_1).id
  end

  def visit_mandate_path
    get mandate_path mandates(:mandate_1).id
  end

  def visit_mandate_market
    get root_url
  end

  def visit_dashboard
    get root_url
  end

  def visit_edit_task_path task_id
    get edit_task_path task_id
  end

  def verify_see_no_attendance(course)
    assert_select (member_of_course_selector course), false, 'Should not see any attendees'
  end

  def verify_see_attendance(course, member)
    get edit_course_path(courses(course).id)
    assert_select (member_of_course_fullname course), members(member).full_name
    assert_select (member_of_course_selector course, 2),
                  false, "There should be no more attendees"
  end

  def attend(event,permit=false)
    patch attend_event_path(courses(event))
    attendance_id = Attendance.last.id
    if permit
      with :sonja do
        patch permit_attendance_path(attendance_id)
      end
    end
    attendance_id
  end

  def unattend(course)
    patch unattend_event_path(courses(course))
  end

  def member_of_course_selector(course, attendee_index = 1)
    ".attendees .row:nth-child(#{attendee_index})"
  end

  def verify_see_contact(department_id, name, suppress_extra_check = false)
    get people_url(params:{department_id: department_id})
    assert_select '.person-info:nth-child(1) .person-name', name
    if not suppress_extra_check
      assert_select '.person-info:nth-child(2)', false, 'There should not be a person'
    end
  end

  def assign_and_approve_mandate_for(member)
    with member do
      apply_for_mandate
    end
    with :sabine do
      approve_latest_assignment
    end
  end

  private

  def member_of_course_fullname(course, attendee_index = 1)
    member_of_course_selector(course,attendee_index)+' .attendee_full_name'
  end

  def _sign_in(member_name)
    post member_session_url,
         params: { member: {email: members(member_name).email,
                            password: "blubblub" }}
  end
end
