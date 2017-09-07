class AddMemberIdToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :member_id, :integer
  end
end
