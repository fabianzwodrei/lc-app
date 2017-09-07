module DepartmentsHelper
	def departments_to_string department_ids
		department_ids.map { |n| DEPARTMENT_TITLES[n] }.join(", ")
	end
end