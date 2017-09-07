# original domain model name: Schulung
class Course < Event
  before_destroy :check_for_attendances
  before_create { |course|
    course.conversation = Conversation.new(private:false)
    course.archive = false
  }
  
  validates_inclusion_of :module, :in => %w( module-1-workshop module-1-lecture module-2 )
  validates :qualification_date, presence: true, if: Proc.new { |c| c.module == 'module-2' }

  has_one :conversation, foreign_key: :event_id

  scope :passed, -> { where('attendances.passed = ?', true) }
  #scope :grouped_by_date_from_now, -> { find_by_sql("SELECT date, id, title FROM (SELECT id, title, type, unnest(dates) AS date FROM events) e WHERE type='Course' AND date >= '#{Date.today}' GROUP BY date, e.id, e.title;").group_by{ |e| e.date.to_date } }

  def types
    ['module-1-workshop','module-1-lecture','module-2']
  end


  private 
    def check_for_attendances
      return unless attendances.any?
      errors[:base] << 'Schulung kann nicht gelöscht werden, da Teilnahmen verknüpft sind.'
      throw :abort
    end
end