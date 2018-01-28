class Attendance < ActiveRecord::Base
	belongs_to :course, foreign_key: :event_id, optional: true
	belongs_to :consultation, foreign_key: :event_id, optional: true
	belongs_to :event, foreign_key: :event_id
	belongs_to :member

  scope :permitted, -> { where(permitted: true) }
  scope :unpermitted, -> { where(permitted: false) }

  def authorized_by member
    return true if (event.type == "Course" && member.departments.include?(SCHULUNGEN))
    return true if (event.type == "Consultation" && member.departments.include?(SPRECHSTUNDE))
  	return true if member.departments.include? event.department_id
  	false
  end
end