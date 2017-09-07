# original domain model name: Finanzdaten eines Mitgliedes
class FeePayment < ActiveRecord::Base
  belongs_to :member
end