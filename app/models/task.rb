class Task < ActiveRecord::Base
	belongs_to :assigned_member, class_name: "Member", foreign_key: 'assigned_member_id', optional: true
	belongs_to :member
	belongs_to :mandate, optional: true

	attr_accessor :deadline_string
	validate :deadline_format
	def deadline_format
		unless deadline_string.blank?
			begin
				self.deadline = Date.parse(deadline_string)
			rescue
				errors.add(:deadline, :invalid)
			end
		end
	end

	validates :title, presence: true

	default_scope { order(created_at: :desc) }

	scope :done, -> { unscoped.where(done: true).order(updated_at: :desc) }
	scope :undone, -> { where(done: false) }

	scope :by_member_and_assignd_to, lambda { |member|
		where("member_id = #{member.id} OR assigned_member_id = #{member.id}")
	}
end