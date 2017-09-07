class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :mandate_id
      t.integer :member_id
      t.date :deadline
      t.boolean :done
      t.integer :author_id
    end
  end
end
