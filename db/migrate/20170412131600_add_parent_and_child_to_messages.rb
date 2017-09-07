class AddParentAndChildToMessages < ActiveRecord::Migration[5.0]
  def change
  	add_column :messages, :children_count, :integer, default: 0
  	add_column :messages, :parent_id, :integer
  end
end
