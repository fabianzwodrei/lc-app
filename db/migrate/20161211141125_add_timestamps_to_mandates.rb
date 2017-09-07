class AddTimestampsToMandates < ActiveRecord::Migration[5.0]
  def change
    add_column(:mandates, :created_at, :datetime)
    add_column(:mandates, :updated_at, :datetime)
  end
end
