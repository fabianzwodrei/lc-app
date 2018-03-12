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

  def full_qualified
    qualification_level == 3
  end

  def passed_courses
    unless @pc
      @pc = courses.includes(:attendances).where("attendances.passed = 't'")
    end

    @pc
  end

  def passed_lectures_A
    passed_courses.find_all { |c| c.is_lecture_A }
  end

  def passed_lectures_B
    passed_courses.find_all { |c| c.is_lecture_B }
  end

  def passed_courses_not_mandatsarbeit
    passed_courses.find_all { |c| !c.is_lecture_mandatsarbeit }
  end

  def passed_mandatsarbeit_courses
    passed_courses.find_all { |c| c.is_lecture_mandatsarbeit } 
  end

  def passed_and_valid_courses_not_gesetzgebung
    passed_courses.find_all { |c| !c.is_lecture_gesetzgebung and c.was_in_past_year }
  end

  def passed_and_valid_gesetzgebung
    passed_courses.find_all { |c| c.is_lecture_gesetzgebung and c.was_in_past_year }.first
  end

  def qualification_level
    if passed_lectures_A.count > 0 and passed_lectures_B.count > 0 and passed_and_valid_gesetzgebung and passed_and_valid_courses_not_gesetzgebung.count > 1 
      return 3
    end
    if passed_lectures_A.count > 0 and passed_lectures_B.count > 0 and passed_mandatsarbeit_courses.count > 0 and passed_courses_not_mandatsarbeit.count > 1
    end
    if passed_lectures_A.count > 0 and passed_lectures_B.count > 0 and passed_mandatsarbeit_courses.count > 0 and passed_courses_not_mandatsarbeit.count > 1
      return 2
    end
    if passed_lectures_A.count > 0 
      return 1
    end
    return 0 # Mitglied
  end

  def stats
    stats = {}
    stats[:mandates_done] = assignments.approved.joins(:mandate).where("status = 'done'").count
    stats[:mandates_undone] = assignments.approved.joins(:mandate).where("status != 'done'").count
    stats
  end
end