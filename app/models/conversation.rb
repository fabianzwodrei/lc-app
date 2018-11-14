class Conversation < ActiveRecord::Base
  has_many :messages
  has_many :conversation_views, dependent: :destroy
  default_scope -> { order('updated_at DESC')}

  belongs_to :mandate, optional: true
  belongs_to :project, optional: true
  
  # PRIVATE CONVERSATIONS
  belongs_to :member1, class_name: "Member", foreign_key: 'member1_id', optional: true
  belongs_to :member2, class_name: "Member", foreign_key: 'member2_id', optional: true

  before_validation :ensure_member1_lower_member2
  # member-ids in ascending order. swapping if otherwise
  def ensure_member1_lower_member2
  	if private? and member1_id > member2_id
  		self.member1_id, self.member2_id = member2_id, member1_id
  	end
  end
  validates :member1_id, uniqueness: { scope: :member2_id }, if: :private?

  scope :privates, lambda { |current_member_id| where('private = ? AND (member1_id = ? OR member2_id = ?)', true, current_member_id, current_member_id) }
  
  # todo: REMOVE ! 
  # scope :unread, lambda { |member|
  #   joins(:conversation_views).
  #       where("conversation_views.member_id = ? AND conversation_views.viewed_at < conversations.updated_at", member.id)}

  def get_other_member member
  	if member1 and member2
  		return member == member2 ? member1 : member2
  	end
  end
  
  def is_unread_by member
    if cv = conversation_views.find_by_member_id(member.id)
      return cv.viewed_at < updated_at
    end
    true
  end

  def is_private_for member
  	return false unless private?
  	[member1_id, member2_id].include? member.id
  end

  def is_open_for member
    if private
      return is_private_for(member)
    elsif mandate_id
      return (mandate.is_assigned_to member or member.departments.include? MANDATSVERWALTUNG)
    elsif project_id
      return ((member.departments & project.departments).any? or project.invitees.include? member)
    elsif event_id
      return ((Course.find event_id).is_attended_by member or member.departments.include? SCHULUNGEN)
    end
    false
  end

  def get_title current_member
    if private
      return get_other_member(current_member).full_name
    elsif mandate_id
      return "Mandat " + mandate.title if mandate
    elsif project_id
      return project.title
    elsif event_id
      return Course.find(event_id).title
    end
    ""
  end

  def get_url
    if project_id
      return "/projects/#{project_id}"
    else
      return "/conversations/#{id}"
    end
  end

  scope :private_between, lambda { |member1_id, member2_id|
  	if member1_id > member2_id
      member1_id, member2_id = member2_id, member1_id
    end
    self.where(member1_id: member1_id, member2_id: member2_id)
  }
end
