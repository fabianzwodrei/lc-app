class AddPublicToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :use_for_infoboard, :boolean, default: false
  end
end
