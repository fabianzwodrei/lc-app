class AddClientRelationToMandate < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :client_id, :integer
  end
end
