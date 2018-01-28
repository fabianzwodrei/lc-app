class Member < ActiveRecord::Base
	devise :database_authenticatable, :rememberable, :trackable, :validatable, :lockable, :timeoutable

  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "/avatar.svg"
  validates_attachment :avatar, content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }
 
  validate :password_complexity

  def password_complexity
    if password.present? and not password.match(/^(?=.*\d)./)
      errors.add :password, "Das Passwort muss mindestens 8 Zeichen lang sein und mindestens eine Zahl enthalten."
    end
  end

	has_many :inquiries
  has_one :fee_payment
  belongs_to :annotation, optional: true

  has_many :conversation_views, dependent: :destroy
  has_many :conversations

	has_many :assignments
  has_many :attendances
	has_many :mandates, through: :assignments
  has_many :courses, through: :attendances
  has_many :events, through: :attendances
  has_many :consultations, through: :attendances
  has_many :tasks
  has_many :documents
  has_many :messages
  has_many :invitations
  has_many :projects, through: :invitations

  validates :last_name, presence: true
  validates :first_name, presence: true

  default_scope { order('LOWER(last_name)') }
  scope :unlocked, -> { where(locked_at: nil) }
  scope :in_department, lambda { |department_id| where("departments @> ARRAY[#{department_id}]") }
  
  scope :with_open_payment, lambda {
    joins(:fee_payment).
        where.not( fee_payments: {paid: true})}

  def full_name
    first_name + ' ' + last_name
  end

  def qualified
    qualification_level > 0
  end

  def qualification_level
    passed_attendances = attendances.select {|t| t.passed}
    m1a_found = 0
    m1b_found = 0
    m2_found = 0

    for attendance in passed_attendances
      c = Course.find attendance.event_id
      m1a_found += 1 if c.module == 'module-1-lecture'
      m1b_found += 1 if c.module == 'module-1-workshop'

      if c.module == 'module-2'
        age = 366
        if c.qualification_date
          age = (Date.today - c.qualification_date).to_i
        end  
        m2_found += 1 if age < 366
      end
    end

    if m1a_found > 0 and m1b_found > 0 and m2_found > 1
      return 2 # vollqualifiziert wenn min. 2 modul-2 Schulungen jünger als ein Jahr
    elsif m1a_found > 0 and m1b_found > 0
      return 1 # qualifiziert
    else
      return 0 # Hospitant*in
    end
  end

  def stats
    stats = {}
    stats[:mandates_done] = assignments.approved.joins(:mandate).where("status = 'done'").count
    stats[:mandates_undone] = assignments.approved.joins(:mandate).where("status != 'done'").count
    stats
  end
end