class AttendancesController < ApplicationController
  load_and_authorize_resource

  def permit
    notice = @attendance.update(permitted: true) ? 'Teilnahme wurde erfolgreich bestätigt.'
                                                : 'Teilnahme konnte nicht gespeichert werden'
    redirect_back notice: notice, fallback_location: root_url
  end

  def unpermit
    notice = @attendance.update(permitted: false) ? 'Teilnahme wurde erfolgreich zurückgenommen.'
                                                 : 'Teilnahme konnte nicht zurückgenommen werden.'
    redirect_back notice: notice, fallback_location: root_url
  end

  def award
    pars = {open:@attendance.event_id}
    pars[:from] = params[:from] if params[:from]

    attendance = Attendance.find params[:id]
    notice = attendance.update(passed:true) ? "'Kurs bestanden' gespeichert."
                                            : "'Kurs bestanden' konnte nicht gespeichert werden."
    redirect_to edit_course_url(attendance.course, anchor: "attendees"), notice: notice
  end

  def unaward
    # @attendance = Attendance.find params[:id]
    pars = {open:@attendance.event_id}
    pars[:from] = params[:from] if params[:from]

    attendance = Attendance.find params[:id]
    notice = attendance.update(passed:false) ? "'Kurs bestanden' zurückgenommen."
                                             : "'Kurs bestanden' konnte nicht zurückgenommen werden."
    redirect_to edit_course_url(attendance.course, anchor: "attendees"), notice: notice
  end
end