class ConvertDateToDateTime < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :dates
    add_column :events, :dates, :datetime, array: true, default: []
  end
end
