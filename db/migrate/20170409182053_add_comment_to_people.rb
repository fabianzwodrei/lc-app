class AddCommentToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :comment, :text
  end
end
