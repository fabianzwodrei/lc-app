class AssignmentsController < ApplicationController

  load_and_authorize_resource
  before_action :set_mandate, only: [:apply, :unapply]

	def update
    if @assignment.update!(approved: true)
      @mandate_for_status_message = @assignment.mandate
      
      redirect_to mandates_url({open: @mandate_for_status_message.id}), notice: 'Zuweisung erfolgreich vorgenommen.'
    end
  end

	def destroy
    if @assignment.approved
      @mandate_for_status_message = @assignment.mandate
    end
		if @assignment.destroy
      if @mandate_for_status_message
        @mandate_for_status_message.conversation.messages.create(text: "Zuweisung für " + @assignment.member.full_name + " wurde entfernt.")
      end
      redirect_to mandates_url({open: @mandate_for_status_message.id}), notice: "Zuweisung/Bewerbung für " + @assignment.member.full_name + " wurde erfolgreich gelöscht."
    end
  end

  def apply
    unless @mandate.assignments.where('member_id' => current_member.id).first.blank?
      return redirect_to public_mandates_url, notice: 'Fehler: Für den Nutzer wurde schon eine Bewerbung/Zuweisung für dieses Mandat registriert.'
    end

    notice = @mandate.assignments.create({member_id: current_member.id}) ?
      'Mandatsbewerbung wurde erfolgreich gespeichert.' :
      'Fehler: Mandatsbewerbung konnte nicht gespeichert werden.'
    redirect_to public_mandates_url, notice: notice
  end

  def unapply
    assignment = @mandate.assignments.where('member_id' => current_member.id).first
    if already_approved assignment
      return redirect_to public_mandates_url, notice: 'Kann Bewerbung nicht mehr zurückziehen, da bereits von der Mandatsverwaltung zugewiesen.'
    end
    assignment.destroy
    redirect_to public_mandates_url, notice: 'Mandatsbewerbung wurde erfolgreich zurückgezogen.'
  end

	private

    def already_approved(assignment)
      not assignment.blank? and assignment.approved
    end

    def set_mandate
      @mandate = Mandate.find(params[:mandate_id])
    end

    def assignment_params
      params.require(:assignment).permit(
          :member_id, :mandate_id, :approved
      )
    end
end