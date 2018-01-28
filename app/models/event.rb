class Event < ActiveRecord::Base


  validates :title, presence: true, allow_blank: false
  validates :where, presence: true, allow_blank: false
  validates :dates_string, presence: true, allow_blank: false

  belongs_to :department, optional: true
  has_many :attendances, foreign_key: :event_id
  has_many :members, through: :attendances

  
  attr_accessor :dates_string
  validate :dates_format
  def dates_format
    unless dates_string.blank?
      self.dates = []
      for string_date in dates_string.split(',')
        begin
          self.dates << DateTime.parse(string_date)
        rescue
          errors.add(:dates, :invalid)
        end
      end
    end
  end


  def full
    return false if limit == nil
    members.length >= limit
  end

  scope :archived, ->             { where('archive = ?', true)}
  scope :active, ->               { where('archive = ?', false)}
  scope :by_department, lambda    { |id| where('department_id = ?',id)}

  scope :unrestricted, ->         { where(department_id: nil)}
  scope :for_departments, lambda  { |departments| where("department_id IN (?)", departments) }

  scope :between, lambda          { |starting,ending| from("events, unnest(dates) date").where("date >= '#{starting}' AND date <= '#{ending}'").distinct  }
  scope :from_now, ->             { from("events, unnest(dates) date").where("date >= '#{Date.today}'").distinct  }

  scope :grouped_by_date_from_now, lambda { |starting, ending| find_by_sql("SELECT date, id, title, type FROM (SELECT id, title, type, unnest(dates) AS date FROM events) e WHERE date >= '#{starting}' and date <= '#{ending}' GROUP BY date, e.id, e.title, e.type;").group_by{ |e| e.date.to_date } }


  def unattendance_possible?(member)
    self.is_attended_by(member,true) and not passed? member
  end

  def attendance_possible?(member)
    not self.full and not self.is_attended_by(member,true)
  end

  def passed?(member)
    test_attendance(member, :passed, false)
  end

  def is_attended_by(member,non_strict=false)
    test_attendance(member, :permitted, non_strict)
  end

  private

  def test_attendance(member, funct, non_strict)
    att = Attendance.where('member_id =? ',member.id).where('event_id = ?',self.id).first
    return false unless att
    return true if non_strict
    if att.send(funct)
      true
    else
      false
    end
  end
end