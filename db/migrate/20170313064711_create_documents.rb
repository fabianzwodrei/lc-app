class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.text :tags
      t.text :comment
      t.references :member
      t.attachment :attachment
      t.timestamps
    end
  end
end
