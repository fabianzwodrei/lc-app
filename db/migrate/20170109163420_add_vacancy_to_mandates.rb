class AddVacancyToMandates < ActiveRecord::Migration[5.0]
  def change
    add_column :mandates, :vacant, :boolean, default: true
  end
end
