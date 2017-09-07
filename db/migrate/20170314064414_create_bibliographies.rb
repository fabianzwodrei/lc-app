class CreateBibliographies < ActiveRecord::Migration[5.0]
  def change
    create_table :bibliographies do |t|
      t.string :title
      t.integer :department_id
    end
  end
end
