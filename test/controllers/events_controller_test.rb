require "test_helper"
class EventsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sonja
  end

  ## attend / unattend

  test 'can attend course' do
    with :svenja do
      attend :course_1
    end
    verify_see_attendance :course_1, :svenja
  end

  test 'can unattend course' do
    with :svenja do
      attend :course_1
      unattend :course_1
    end
    get courses_url
    verify_see_no_attendance :course_1
  end

  test 'can attend course with limit' do
    with :svenja do
      attend :course_limited
    end
    verify_see_attendance :course_limited, :svenja
  end

  test 'cannot attend course with limit when full' do
    attend :course_limited
    with :svenja do
      attend :course_limited
    end
    verify_see_attendance :course_limited, :sonja
  end

  test 'can attend course with limit when someone unattends' do
    attend :course_limited
    unattend :course_limited
    with :svenja do
      attend :course_limited
    end
    verify_see_attendance :course_limited, :svenja
  end

  test 'can attend course with limit and permission required' do
    with :svenja do
      attend :course_limited_and_permission_required
    end
    verify_see_attendance :course_limited_and_permission_required, :svenja
  end

  test 'cannot attend course with limit and permission required' do
    attend :course_limited_and_permission_required
    with :svenja do
      attend :course_limited_and_permission_required
    end
    verify_see_attendance :course_limited_and_permission_required, :sonja
  end

  test 'cannot unattend course if it has been awarded' do
    attendance_id=nil
    with :svenja do
      attendance_id=attend :course_1
    end
    patch award_attendance_path(attendance_id)
    with :svenja do
      unattend :course_1
    end
    verify_see_attendance :course_1, :svenja
  end

  ## index

  test 'can see an attended course in event listing' do
    let_svenja_attend_new_course
    verify_event_is_in_listing mkdt, 'someCourse'
  end

  test 'can see a closed course when attendance is permitted' do
    let_svenja_attend_new_course true, true
    verify_event_is_in_listing mkdt, 'someCourse'
  end

  test 'cannot see a closed course when attendance is not permitted' do
    let_svenja_attend_new_course true, false
    verify_event_is_in_listing false, false
  end

  test 'can see course with two individual dates' do
    let_svenja_attend_new_course false, false, mkdt+','+mkdt
    verify_event_is_in_listing mkdt, 'someCourse'
    verify_event_is_in_listing mkdt, 'someCourse', 2
  end

  test 'can see only current dates' do
    let_svenja_attend_new_course false, false, mkdt(-1)+','+mkdt+','+mkdt(1)
    verify_event_is_in_listing mkdt, 'someCourse'
    verify_event_is_in_listing mkdt(1), 'someCourse', 2
    verify_event_is_in_listing false, false, 3
  end

  test 'can see past dates on demand' do
    let_svenja_attend_new_course false, false, mkdt(-1)+','+mkdt+','+mkdt(1)
    verify_event_is_in_listing mkdt(-1), 'someCourse', 1, {params: {past: true}}
    verify_event_is_in_listing false, false, 2, {params: {past: true}}
  end

  test 'can see it in date order, regardless of type' do
    create_consultation mkdt(2)
    let_svenja_attend_new_course false, false, mkdt(1)+','+mkdt(5)
    verify_event_is_in_listing mkdt(1), 'someCourse', 1
    verify_event_is_in_listing mkdt(2), 'one', 2
    verify_event_is_in_listing mkdt(5), 'someCourse', 3
    verify_event_is_in_listing false, false, 4
  end

  test 'can see it in reverse date order for past events' do
    create_consultation mkdt(-3)
    let_svenja_attend_new_course false, false, mkdt(-1)
    verify_event_is_in_listing mkdt(-1), 'someCourse', 1, {params: {past: true}}
    verify_event_is_in_listing mkdt(-3), 'one', 2, {params: {past: true}}
    verify_event_is_in_listing false, false, 3, {params: {past: true}}
  end

  test 'cannot see an attended course of other member' do
    let_svenja_attend_new_course
    sign_in :sonja
    verify_event_is_in_listing false, false
  end

  ## index -- consultations

  test 'can see an attended consultation if permitted' do
    let_martha_attend_consultation true, true
    verify_event_is_in_listing mkdt, 'someConsultation'
  end

  test 'cannot see an attended consultation if not permitted' do
    let_martha_attend_consultation true, false
    verify_event_is_in_listing false, false
  end

  test 'cannot see an attended consultation of another member' do
    let_martha_attend_consultation true, true
    sign_in :sonja
    verify_event_is_in_listing false, false
  end

  test 'ignore if more than one time was specified for consultation' do
    let_martha_attend_consultation true, true, mkdt(2)+','+mkdt(3)
    verify_event_is_in_listing mkdt(2), 'someConsultation'
    verify_event_is_in_listing false, false, 2
  end



  private

    def create_consultation(dates)
      sign_in :svenja
      with :martha do
        post consultations_url,
             params: { consultation: { title: 'one', where: 't', dates_string: dates }}
      end
      attendance_id = nil
      with :svenja do
        patch attend_event_path(Consultation.maximum(:id))
        attendance_id = Attendance.last.id
      end
      with :martha do
        patch permit_attendance_path(attendance_id)
      end
      sign_in :sonja
    end

    def verify_event_is_in_listing(date, title, nr = 1, params = nil)
      get events_url(params)
      assert_select "#event_listing #event-#{nr} .dates", date
      assert_select "#event_listing #event-#{nr} .title", title
    end

    def let_martha_attend_consultation(permission_required = false, permit = false, dates = mkdt)
      sign_in :martha
      post consultations_url,
           params: { consultation: {
               title: 'someConsultation',
               dates_string: dates,
               where: 't',
               permission_required: permission_required}}

      if Consultation.last
        patch attend_event_path(Consultation.last.id)
        if permit
          patch permit_attendance_path Attendance.last.id
        end
      end
    end

    def let_svenja_attend_new_course(permission_required = false, permit = false, dates = mkdt)
      post courses_url,
           params: {
               course: {
                 title: 'someCourse',
                 module: 'module-1-lecture',
                 dates_string: dates,
                 where: 't',
                 permission_required: permission_required
               }
           }
      sign_in :svenja
      patch attend_event_path(Course.last.id)

      if permit
        with :sonja do
          patch permit_attendance_path Attendance.last.id
        end
      end
    end

    def mkdt(diff=0)
      (Date.today + diff).strftime('%d.%m.%Y')+' - 13:30'
    end
end