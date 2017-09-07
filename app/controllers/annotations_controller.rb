class AnnotationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_annotation, only: [:show,:update]

  def show
  end

  def update
    if @annotation.update(annotation_params)
      redirect_to edit_annotation_path(@annotation), notice: 'Kommentar wurde erfolgreich aktualisiert.'
    end
  end

  def edit
    set_annotation
  end

  private

  def set_annotation
    @annotation = Annotation.find(params[:id])
  end

  def annotation_params
    params.require(:annotation).permit(:text)
  end
end