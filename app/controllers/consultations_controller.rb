class ConsultationsController < EventsController

  load_and_authorize_resource

  before_action :load_consultation, only: [:edit]
  before_action :load_consultations, only: [:index,:public_index]


  def index
    @open_consultation_id = (params[:open] if params[:open]).to_i
  end

  def new
    @consulatation = Consultation.new
  end

  def edit
  end

  def create
    @consultation.limit = 6
    @consultation.archive = false
    @consultation.permission_required = true
    if @consultation.save
      redirect_to consultations_path, notice: 'Sprechstunde wurde erfolgreich angelegt.'
    else
      render action: 'new'
    end
  end

  def email
      @consultation.attendances.permitted.each do |attendance|
        MailWorker.perform_async(
          JSON.generate( m_id: attendance.member_id, email_subject: "RLCC Sprechstunde: - " + params[:email_subject], email_body: params[:email_body] )
        )
      end
      head :ok, content_type: "text/html"
  end

  def update
    if @consultation.update(consultation_params)
      redirect_to consultations_path, notice: 'Sprechstunde wurde erfolgreich aktualisiert.'
    else
      render action: 'show'
    end
  end

  def destroy
    if @consultation.destroy
      redirect_to consultations_path, notice: 'Die Veranstaltung wurde erfolgreich gelöscht.'
    end
  end

  private

  def load_consultation
    @consultation = Consultation.find(params[:id])
  end

  def load_consultations
    @consultations, @from, @count = load_events Consultation
  end

  def consultation_params
    params.require(:consultation).permit(
        :title,:where,:archive,:dates_string)
  end
end