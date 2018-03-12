class NewQualificationSystem < ActiveRecord::Migration[5.0]
  def change
  	rename_column 	:events, :module, :category1
  	add_column 		:events, :category2, :string, default: ''
  end
end
