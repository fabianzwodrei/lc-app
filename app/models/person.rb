class Person < ActiveRecord::Base
  before_destroy :check_for_mandates
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :email, presence: true, if: 'phone.blank?'
  validates :department_id, presence: true
  validates_inclusion_of :role, :in => %w( client contact consultant translator )

  belongs_to :inquiry
  has_many :mandates, foreign_key: 'client_id'

  default_scope { order('LOWER(last_name)') }

  def name
    first_name + " " + last_name
  end

  def editable_by member
    if department_id
      return true if member.departments.include? department_id
    else
      # a person without department can be edited by all member with at least 1 department
      return true if member.departments.any?
    end
    false
  end

  def editable_through_mandate_by member
    # member is allowed to edit person if they are connected through a assigned mandate
    mandates.each do |m|
      return true if m.is_assigned_to member
    end
    false
  end

  private 
    def check_for_mandates
      return unless mandates.any?
      errors[:base] << 'Kontakt kann nicht gelöscht werden, da ein Mandat verknüpft ist.'
      throw :abort
    end
end