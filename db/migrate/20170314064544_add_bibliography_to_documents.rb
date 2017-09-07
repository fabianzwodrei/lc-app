class AddBibliographyToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_reference :documents, :bibliography, foreign_key: true
  end
end
