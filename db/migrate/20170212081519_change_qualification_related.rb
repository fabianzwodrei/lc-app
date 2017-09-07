class ChangeQualificationRelated < ActiveRecord::Migration[5.0]
  def change
    rename_column :events,:provides_level,:module
    add_column :attendances,:passed,:boolean
    remove_column :mandates,:requires_level
    remove_column :members,:levels
  end
end
