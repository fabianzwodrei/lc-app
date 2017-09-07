class ReplaceVacancyAndDoneWithStatusInMandates < ActiveRecord::Migration[5.0]
  def change
  	remove_column :mandates, :done
  	remove_column :mandates, :vacant
  	add_column :mandates, :status, :string, default: "vacant", null: false
  end
end
