# original domain model name: Schulung
class Course < Event
  before_destroy :check_for_attendances, :check_used_conversation
  before_create { |course|
    course.conversation = Conversation.new(private:false)
    course.archive = false
  }
  
  validates_inclusion_of :module, :in => %w( module-1-workshop module-1-lecture module-2 )
  validates :qualification_date, presence: true, if: Proc.new { |c| c.module == 'module-2' }

  has_one :conversation, foreign_key: :event_id, dependent: :destroy

  scope :passed, -> { where('attendances.passed = ?', true) }

  def types
    ['module-1-workshop','module-1-lecture','module-2']
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