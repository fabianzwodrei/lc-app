class AddDoneToMandates < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :done, :boolean
  end
end
