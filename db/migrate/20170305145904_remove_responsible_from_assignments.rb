class RemoveResponsibleFromAssignments < ActiveRecord::Migration[5.0]
  def change
    remove_column :assignments, :responsible
  end
end
