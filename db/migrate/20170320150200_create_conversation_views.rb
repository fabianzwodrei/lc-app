class CreateConversationViews < ActiveRecord::Migration[5.0]
  def change
    create_table :conversation_views do |t|
      t.references :conversation, foreign_key: true
      t.references :member, foreign_key: true
      t.datetime :viewed_at
    end
  end
end
