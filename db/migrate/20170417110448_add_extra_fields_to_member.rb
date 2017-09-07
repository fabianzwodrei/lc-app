class AddExtraFieldsToMember < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :course_of_studies, :string
    add_column :members, :semester_count, :string
    add_column :members, :hobbies, :string
  end
end
