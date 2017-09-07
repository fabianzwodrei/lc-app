class Assignment < ActiveRecord::Base
	belongs_to :mandate
	belongs_to :member

	scope :approved, -> { where(approved: true) }
	scope :unapproved, -> { where(approved: false) }

	after_save {
		if approved_changed?
			if approved
				mandate.conversation.messages.create(text: member.full_name + " zugewiesen") 
			else
				mandate.conversation.messages.create(text: "Zuweisung für " + member.full_name + " wurde entfernt.")
			end
		end
	}

	
end