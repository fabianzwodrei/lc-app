class RenamePersonColumnInInquries < ActiveRecord::Migration[5.0]
  def change
  	rename_column :inquiries, :person_id, :client_id
  end
end
