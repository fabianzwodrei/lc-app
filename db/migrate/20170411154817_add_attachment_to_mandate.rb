class AddAttachmentToMandate < ActiveRecord::Migration[5.0]
	def up
		add_attachment :mandates, :attachment
	end

	def down
		remove_attachment :mandates, :attachment
	end
end
