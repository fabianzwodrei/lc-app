class Bibliography < ActiveRecord::Base
	has_many :documents, -> { order "created_at DESC" }, dependent: :destroy

	def editable_by member
		if department_id
			return true if member.departments.include? department_id
		else
			return member.departments.any?
		end
	end
end