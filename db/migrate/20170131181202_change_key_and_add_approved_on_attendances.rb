class ChangeKeyAndAddApprovedOnAttendances < ActiveRecord::Migration[5.0]
  def change
    rename_column :attendances, :course_id, :event_id
    add_column :attendances, :approved, :boolean
  end
end
