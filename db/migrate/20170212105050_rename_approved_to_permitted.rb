class RenameApprovedToPermitted < ActiveRecord::Migration[5.0]
  def change
    rename_column :attendances, :approved, :permitted
  end
end
