class ProjectsController < ApplicationController
  load_and_authorize_resource 

  # def index
  # 	@projects = Project.where("archived = false AND (departments && ARRAY[#{current_member.departments}])")
  # end

  def archived
    @department_projects = Project.where("archived = true AND (departments && ARRAY[#{current_member.departments}])") if current_member.departments.any?
    @projects_with_invitation = current_member.projects.where(archived: true)
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Projekt wurde erfolgreich gespeichert.'
    else
      render action: 'edit'
    end
  end

	def new
  	@project = Project.new
    # pre-select departments
    @project.departments = params["preselect"] ?  [params["preselect"]] : current_member.departments
  end

  def show
  	    ConversationView.create_or_update_for @project.conversation.id, current_member.id

  end

  def create
    @project.conversation = Conversation.create()
  	if @project.save
      redirect_to @project, notice: 'Projekt wurde erfolgreich angelegt.'
    else
      render action: 'new'
    end
  end

  def add_member
    member = Member.find(params[:member_id])
    if member == nil or @project.invitees.include? member
      ntce = "Fehler. Das Mitglied ist bereits eingeladen oder unbekannt."
    else
      @project.invitees << member
      ntce = "Mitglied wurde eingeladen"
      # ensure that conversion appears as unread
      member.conversation_views.create(conversation: @project.conversation, viewed_at: @project.conversation.updated_at-1.hour)
    end
    redirect_to edit_project_path(@project), notice: ntce
  end

  def remove_member
    member = Member.find(params[:member_id])
    if member == nil or !@project.invitees.include? member
      ntce = "Fehler. Das Mitglied ist nicht eingeladen oder unbekannt."
    else
      @project.invitees.delete member
      ntce = "Mitglied wurde ausgeladen"
    end
    redirect_to edit_project_path(@project), notice: ntce
  end

 	private


  def project_params
    _params = params.require(:project).permit(:title, :description, :archived, :use_for_infoboard, :departments => [])
		_params[:departments].reject!(&:blank?) if _params[:departments]
		_params
  end

end