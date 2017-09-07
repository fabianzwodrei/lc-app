class AddCodeToMandates < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :code, :string
  end
end
