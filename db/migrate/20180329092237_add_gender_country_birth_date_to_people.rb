class AddGenderCountryBirthDateToPeople < ActiveRecord::Migration[5.0]
  def change

  	add_column :people, :country_of_origin, :string
    add_column :people, :date_of_birth, :date
    add_column :people, :gender, :string
  end
end
