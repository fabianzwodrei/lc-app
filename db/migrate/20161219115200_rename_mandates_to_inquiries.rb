class RenameMandatesToInquiries < ActiveRecord::Migration[5.0]
  def change
    rename_table :mandates, :inquiries
  end
end
