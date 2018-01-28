class Message < ActiveRecord::Base
	after_create {
		if parent
			parent.children_count += 1
			parent.save
		end
	}

	after_create_commit {
		MessageBroadcastJob.perform_later self
		conversation.update(updated_at: Time.now)
	}

	validates :conversation_id, presence: true

	scope :parents_only, -> { where('parent_id is NULL') }
	scope :timeline_order, -> { order("created_at DESC") }
	scope :chat_order, -> { order("created_at ASC") }

	has_many :children, class_name: "Message", foreign_key: "parent_id"
	belongs_to :parent, class_name: "Message", optional: true

	belongs_to :member, optional: true
	belongs_to :conversation, optional: true
  	has_attached_file :attachment,
                    	url: '/:class/:id/attachment',
                    	path: ':rails_root/user_files/:class/:id/:attachment'
    validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","application/vnd.oasis.opendocument.text", "application/vnd.oasis.opendocument.spreadsheet"]
end	