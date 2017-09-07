class RenameUploadsInMessages < ActiveRecord::Migration[5.0]
  def change

  	rename_column :messages, :upload_file_name, :attachment_file_name
  	rename_column :messages, :upload_content_type, :attachment_content_type
  	rename_column :messages, :upload_file_size, :attachment_file_size
  	rename_column :messages, :upload_updated_at, :attachment_updated_at
  end
end
