class AddPeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.string :name
      t.string :role
      t.string :email
      t.string :phone
      t.string :languages
    end
  end
end
