class Addlevels < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :requires_level, :string
    add_column :members, :levels, :string
    add_column :events, :provides_level, :string
  end
end
