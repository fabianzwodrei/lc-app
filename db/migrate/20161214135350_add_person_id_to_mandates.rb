class AddPersonIdToMandates < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :person_id, :integer
  end
end
