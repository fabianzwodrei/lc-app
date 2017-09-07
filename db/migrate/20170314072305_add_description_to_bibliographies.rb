class AddDescriptionToBibliographies < ActiveRecord::Migration[5.0]
  def change
    add_column :bibliographies, :description, :text
  end
end
