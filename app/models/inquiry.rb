class Inquiry < ActiveRecord::Base
  belongs_to :member, :foreign_key => 'member_id', optional: true
  belongs_to :client, class_name: "Person", foreign_key: 'client_id', optional: true

  validates :client, presence: true

  accepts_nested_attributes_for :client

  default_scope { order(updated_at: :desc) }
  scope :done, -> { where('done = ?', true) }
  scope :undone, -> { where('done != ?', true) }
  scope :for_client, lambda { |client|
     where('client_id = ?',client.id)
  }
end