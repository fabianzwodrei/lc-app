class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.integer :departments, array:true, default: []
      t.boolean :archived, default: false
      t.timestamps
    end
  end
end
