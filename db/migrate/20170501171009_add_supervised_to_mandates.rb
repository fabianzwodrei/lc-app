class AddSupervisedToMandates < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :supervised, :boolean, :null => false, :default => false
  end
end
