class AddPublicToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :public, :boolean, default: false
  end
end
