class CreateMandates < ActiveRecord::Migration[5.0]
  def change
    create_table :mandates do |t|
      t.integer :member_id
      t.boolean :simple
      t.string :title
    end
  end
end
