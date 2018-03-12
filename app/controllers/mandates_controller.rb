class MandatesController < ApplicationController

  include PeopleHelper

  load_and_authorize_resource
	before_action :set_mandate, only: [:edit, :update, :request_review]

  def add_member
    member = Member.find params[:member_id]
    if member == nil or @mandate.is_assigned_to member
      return redirect_to mandates_path, notice: 'Fehler. Das Mitglied ist entweder unbekannt oder bereits als Bearbeiter hinzugefügt.'
    end

    unless as = Assignment.find_by(member_id: member.id, mandate_id: @mandate.id) 
      as = @mandate.assignments.create(member_id: member.id)
    end
    as.update(approved:true)

    redirect_to mandates_path({open: @mandate.id}), notice: "#{member.full_name} wurde erfolgreich als Bearbeiter hinzugefügt."
  end

  def edit
  end

  def new
  	@mandate = Mandate.new
    @department_id = params[:department_id]
  end

  def public_index
    @vacant_mandates = Mandate.vacant
  end

  def index
    if params['supervision'] and params['supervision'] == 'true'
      @mandates = Mandate.undone.order('updated_at DESC').where('supervised = ?',false)
      @supervision = true
    elsif params['from']
      @from = params['from'].to_i
      @count = Mandate.done.count
      @mandates = Mandate.done.order('updated_at DESC').offset(params['from']).limit(Rails.configuration.x.page_items)
    else
  	  @mandates = Mandate.undone
    end
  end

  def get_attachment
      head(:not_found) and return if (@mandate = Mandate.find(params[:id])).nil? or not @mandate.attachment.exists?
      head(:bad_request) and return unless File.exist?(@mandate.attachment.path)
        
      send_file_options = { filename: @mandate.attachment_file_name, :type => @mandate.attachment_content_type }
      send_file(@mandate.attachment.path, send_file_options)
  end

  def request_review
    return redirect_to mandate_path(@mandate),
       notice: 'Erforderliche Qualifikationen nicht vorhanden.' unless current_member.full_qualified

    @mandate.status = "awaits_review"
    if @mandate.save
      redirect_back(
          notice: 'Die Anfrage zur Abnahme des Mandats wurde gespeichert.',
          fallback_location: root_url
      )
    end
  end

  def create
    @mandate.code = SecureRandom.urlsafe_base64 8

    if @mandate.save
      notice = 'Mandat wurde erfolgreich hinzugefügt.'
      return redirect_to root_path, notice: notice if params[:department_id].to_i == SPRECHSTUNDE
      redirect_to mandates_path, notice: notice
    else
      render action: 'new'
    end
  end

  def update
    if not can? :manage, Mandate and trying_to_change_client
      return redirect_back(
          notice: 'Fehler: Nur Mitglieder der Mandatsverwaltung können die Mandatenzuordnung ändern.',
          fallback_location: root_url
      )
    end

  	if @mandate.update(mandate_params)
      redirect_to edit_mandate_path, notice: 'Mandat wurde erfolgreich aktualisiert.'
    else
      render action: 'edit'
    end
  end

  private

    def trying_to_change_client
      params['mandate']['client_id'] and @mandate.client_id != params['mandate']['client_id'].to_i
    end

    def set_mandate
      @mandate = Mandate.find(params[:id])
    end

    def mandate_params
      set_client_attrs(params.require(:mandate).permit(
          :title, :description, :supervised, :status, :client_id, :attachment, :code, client_attributes: permitted_client_attrs
      ))
    end
end