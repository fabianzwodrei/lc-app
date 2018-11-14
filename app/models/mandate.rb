class Mandate < ActiveRecord::Base
	has_many :assignments, dependent: :destroy
	has_many :members, through: :assignments
  has_many :tasks
  has_one :conversation

  validates :title, presence: true, allow_blank: false

  belongs_to :client, class_name: "Person", foreign_key: 'client_id', optional: true
  accepts_nested_attributes_for :client

  has_attached_file :attachment,
                      url: '/:class/:id/attachment',
                      path: ':rails_root/user_files/:class/:id/:attachment'
  validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","application/vnd.oasis.opendocument.text", "application/vnd.oasis.opendocument.spreadsheet"]

  after_create :create_protocol

	default_scope { order(updated_at: :desc) }

  def create_protocol
    unless self.conversation
      self.conversation = Conversation.create()
    end
  end

  def eql?(other_obj)
    id == other_obj.id
  end

  def hash
    id.to_i
  end

  def vacant
    status == "vacant"
  end

  def done
    status == "done"
  end
  def active
    status == "active"
  end

  def is_assigned_to member_or_member_id
    member_or_member_id = member_or_member_id.id if member_or_member_id.class == Member
    assignments.approved.pluck(:member_id).include? member_or_member_id
  end

  scope :done, -> { where("status = 'done'") }
  scope :undone, -> { where("status != 'done'") }
  scope :active, -> { where("status = 'active'") }

  scope :unapproved, -> { where("assignments.approved != ?", true)}
  scope :approved, -> { where("assignments.approved = ?", true)}

  scope :vacant, -> { where("status = 'vacant'") }

  def application_exists_from(current_member)
    assignments.unapproved.pluck(:member_id).include? current_member.id
  end

end