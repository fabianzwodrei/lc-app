class AddUploadToMessage < ActiveRecord::Migration[5.0]
	def up
		add_attachment :messages, :upload
	end

	def down
		remove_attachment :messages, :upload
	end
end
