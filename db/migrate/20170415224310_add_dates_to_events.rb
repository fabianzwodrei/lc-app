class AddDatesToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :dates, :text, array: true, default: []
  end
end
