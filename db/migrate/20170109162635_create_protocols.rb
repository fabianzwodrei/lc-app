class CreateProtocols < ActiveRecord::Migration[5.0]
  def change
    create_table :protocols do |t|
    end
    create_table :messages do |t|
      t.integer :protocol_id
      t.timestamps
    end
    add_column :departments, :protocol_id, :integer
  end
end
