class DocumentsController < ApplicationController

  load_and_authorize_resource 

  before_action :set_document, only: [:update, :edit, :show, :get_attachment, :destroy]

  def new
    @bibliography = Bibliography.find(params[:bibliography_id])
  	@document = Document.new
  end

  def edit
  end

  def create
    @bibliography = Bibliography.find(params[:bibliography_id])

  	@document = @bibliography.documents.new(document_params.merge({member_id: current_member.id}))
    if @document.save
      redirect_to bibliography_path(@bibliography), notice: 'Dokument wurde erfolgreich hinzugefügt.'
    else
      render action: 'new'
    end
  end

  def update
    if @document.update(document_params)
      redirect_back(
          notice: 'Dokument wurde erfolgreich aktualisiert.',
          fallback_location: root_path
      )
    end
  end

  def get_attachment
		head(:not_found) and return if @document.nil? or not @document.attachment.exists?
		head(:bad_request) and return unless File.exist?(@document.attachment.path)
		  
		send_file_options = { filename: @document.attachment_file_name, type: @document.attachment_content_type }
		send_file(@document.attachment.path, send_file_options)
	end

  def thumbnail
    head(:not_found) and return if @document.nil? or not @document.attachment.exists?
    head(:bad_request) and return unless File.exist?(@document.attachment.path(:thumb))
      
    send_file_options = { filename: @document.attachment_file_name, type: "png" }
    send_file(@document.attachment.path(:thumb), send_file_options)
  end


  def destroy
    @bibliography = @document.bibliography
    if @document.destroy
      redirect_to bibliography_path(@bibliography), notice: 'Dokument wurde erfolgreich gelöscht.'
    end
  end


  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title,:tags,:comment,:attachment)
  end
end