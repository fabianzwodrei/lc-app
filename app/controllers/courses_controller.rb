class CoursesController < EventsController

  load_and_authorize_resource

  before_action :load_course, only: [:edit, :show,:apply,:email]
  before_action :load_courses, only: [:index, :public_index]


  def index
  end

  def add_member
    add_member_to_event(@course,(Member.find params[:member_id]),params[:from])
  end

  def remove_member
    remove_member_from_event(@course,(Member.find params[:member_id]),params[:from])
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def destroy
    if @course.destroy
      redirect_to courses_path(), notice: 'Schulung wurde erfolgreich gelöscht.'
    else
      head :precondition_failed
    end
  end

  def email
      @course.attendances.permitted.each do |attendance|
        MailWorker.perform_async(
          JSON.generate( m_id: attendance.member_id, email_subject: "RLCC Schulungen: - " + params[:email_subject], email_body: params[:email_body] )
        )
      end
      head :ok, content_type: "text/html"
  end

  def update
    if @course.update(course_params)
      redirect_to courses_path, notice: 'Veranstaltung wurde erfolgreich aktualisiert.'
    else
      render 'edit'
    end
  end

  def create
    if @course.save
      if request.format == :json
        render :json => @course
      else
        redirect_to courses_path, notice: 'Veranstaltung wurde erfolgreich hinzugefügt.'
      end
    else
      render action: 'new'
    end
  end

  private

  def load_course
    @course = Course.find(params[:id])
  end

  def load_courses
    @courses, @from, @count = load_events Course
  end

  def course_params
    params.require(:course).permit(
        :title,:when,:where,:limit,:category1,:category2,:permission_required,:description,:archive,:qualification_date,:dates_string)
  end
end