class CreateJoinTableDepartmentsMembers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :departments, :members do |t|
      t.index [:department_id, :member_id]
      t.index [:member_id, :department_id]
    end
  end
end
