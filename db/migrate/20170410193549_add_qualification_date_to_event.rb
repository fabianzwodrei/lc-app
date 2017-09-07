class AddQualificationDateToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :qualification_date, :date
  end
end
