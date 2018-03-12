# original domain model name: Schulung
class Course < Event
  before_destroy :check_for_attendances, :check_used_conversation
  before_create { |course|
    course.conversation = Conversation.new(private:false)
    course.archive = false
  }
  
  validates_inclusion_of :category1, in: COURSE_CATEGORIES.keys.map { |e| e.to_s  }
  validates :category2, presence: true, inclusion: { :in => lambda{ | course | COURSE_CATEGORIES[course.category1.to_sym] }}
  
  validates :qualification_date, presence: true, if: Proc.new { |c| c.category1 == "workshop" }

  has_one :conversation, foreign_key: :event_id, dependent: :destroy

  scope :passed, -> { where('attendances.passed = ?', true) }

  def was_in_past_year
    if category1 == 'workshop'
        if qualification_date
          age = (Date.today - qualification_date).to_i
          return true if age < 366
        end
    end
    false
  end

  def is_lecture_A
    category1 == 'lecture' and category2 == 'A'
  end
  def is_lecture_B
    category1 == 'lecture' and category2 == 'B'
  end

  def is_lecture_mandatsarbeit
    category1 == 'workshop' and category2 == 'C'
  end
  
  def is_lecture_gesetzgebung
    category1 == 'workshop' and category2 == 'D'
  end

  private 
    def check_for_attendances
      return unless attendances.any?
      errors[:base] << 'Schulung kann nicht gelöscht werden, da Teilnahmen verknüpft sind.'
      throw :abort
    end

    def check_used_conversation
      return unless conversation.messages.any?
      errors[:base] << 'Schulung kann nicht gelöscht werden, da Nachrichten verknüpft sind.'
      throw :abort
    end
end