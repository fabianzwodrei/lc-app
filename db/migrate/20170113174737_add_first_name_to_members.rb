class AddFirstNameToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :first_name, :string
  end
end
