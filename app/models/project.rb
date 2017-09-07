class Project < ActiveRecord::Base
	has_one :conversation, dependent: :destroy
	has_many :invitations, dependent: :destroy
	has_many :invitees, through: :invitations, source: :member

	scope :active, ->               { where('archived = ?', false)}
	scope :by_department, lambda { |department_id| where("departments = ARRAY[#{department_id}]") }
	scope :shared_by_departments, lambda { |departments| where("departments && ARRAY[#{departments}] AND array_length(departments, 1) > 1") }
	def edited_by? member
		(departments & member.departments).any?
	end

	def seen_by? member
		return true if (departments & member.departments).any? or invitees.include? member
		false
	end
end
