class BibliographiesController < ApplicationController
  load_and_authorize_resource
  before_action :set_bibliography, only: [ :edit, :show]

  def new
    @bibliography = Bibliography.new
  end

  def create
    @bibliography = Bibliography.new(bibliography_params)
    if @bibliography.save
      redirect_to bibliographies_path(department_id: @bibliography.department_id), notice: 'Bibliographie wurde erfolgreich hinzugefügt.'
    else
      render action: 'new'
    end
  end

  def show
    
  end

  def index
    if params[:department_id] 
      department_id = params[:department_id].to_i
      render plain: "Access denied", status: 403 unless current_member.departments.include? department_id
      @bibliographies = Bibliography.where(department_id: department_id)
    else
      @bibliographies = Bibliography.where(department_id: nil)
    end
  end

  def edit
  end

  def update
    # avoid moving bibliography between departments
    bibliography_params.delete(:department_id)

    if @bibliography.update(bibliography_params)
      redirect_to bibliography_path(@bibliography), notice: 'Bibliographie wurde erfolgreich aktualisiert.'
    end
  end

  def destroy
    if @bibliography.destroy
      redirect_to bibliographies_path(department_id: @bibliography.department_id), notice: 'Bibliographie wurde erfolgreich gelöscht.'
    end
  end

  private
    def set_bibliography
      @bibliography = Bibliography.find(params[:id])
    end
    def bibliography_params
      params.require(:bibliography).permit(:title,:department_id,:description)
    end
end