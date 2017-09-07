class AddDefaultToMember < ActiveRecord::Migration[5.0]
  def change
  	change_column :members, :email, :string, default: ""
  	change_column :members, :email, :string, null: false
  end
end
