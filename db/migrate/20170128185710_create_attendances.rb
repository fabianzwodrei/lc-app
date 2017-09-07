class CreateAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.integer :course_id
      t.integer :member_id
    end
  end
end
