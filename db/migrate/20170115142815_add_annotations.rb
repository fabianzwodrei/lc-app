class AddAnnotations < ActiveRecord::Migration[5.0]
  def change
    create_table :annotations do |t|
      t.text :text
      t.integer :member_id
    end
  end
end
