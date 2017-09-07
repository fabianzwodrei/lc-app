# original domain model name: Mandatsverwaltungskommentar
class Annotation < ActiveRecord::Base
  has_one :member
end