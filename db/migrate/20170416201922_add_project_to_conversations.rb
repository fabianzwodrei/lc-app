class AddProjectToConversations < ActiveRecord::Migration[5.0]
  def change
    add_reference :conversations, :project, foreign_key: true
  end
end
