class Document < ActiveRecord::Base
	belongs_to :member
	belongs_to :bibliography
	has_attached_file :attachment,
                    	path: ':rails_root/user_files/:class/:id/:style/:basename.:extension',
                    	styles: lambda { |a|  if a.content_type =~ %r(image|pdf) then return { :thumb => ["300x300>", :png] } else return {} end  } 
    validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet","application/vnd.oasis.opendocument.text", "application/vnd.oasis.opendocument.spreadsheet"]
                    		
 	#    before_post_process :skip_other_attachments_than_images
	# def skip_other_attachments_than_images
	#     ! %w(image pdf).include? attachment_content_type
	# end
end