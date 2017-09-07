class TasksController < ApplicationController

  load_and_authorize_resource 
  before_action :load_task, only: [:close, :update, :edit]

  def new
    @task = Task.new
  end

  def done
    if params[:filter]
      @tasks = Task.done.where(mandate_id: params[:filter][:mandate_id]) if params[:filter][:mandate_id]
      @tasks = Task.done.where(department_id: params[:filter][:department_id]) if params[:filter][:department_id]
    else
      @tasks = Task.done.by_member_and_assignd_to current_member
    end
  end

  def index
    if params[:origin]
      @origin = params[:origin]
    elsif request.referer
      @origin = URI(request.referer).path
    end
    
    if params[:filter]
      @tasks = Task.undone.where(mandate_id: params[:filter][:mandate_id]) if params[:filter][:mandate_id]
      @tasks = Task.undone.where(department_id: params[:filter][:department_id]) if params[:filter][:department_id]
    else
      @tasks = Task.undone.by_member_and_assignd_to current_member
    end

    if request.format == :htmlp
      render partial: "listing", formats: [:html], locals: {tasks: @tasks}, layout: false
    else
      redirect_to root_path, notice: 'Aufgabe wurde erfolgreich hinzugefügt.'
    end
  end

  def close
  	@task.update({done: true})
  	index
  end

  def create
    @task = current_member.tasks.new(task_params)
    if @task.save
    	index
    else
      render action: 'new'
    end
  end

  def update
    if @task.update(task_params)
      notice = 'Änderungen an Aufgabe gespeichert.'
      if params[:origin]
        redirect_to params[:origin], notice: notice
      else
        redirect_back(
          notice: notice,
          fallback_location: root_url
        )
      end
    else
      render action: 'edit'
    end
  end

  def edit

  end

  private
    def load_task
        @task = Task.find(params[:id])
    end
		def task_params
      if params[:task][:assigned_member_id] && params[:task][:assigned_member_id] == current_member.id.to_s
        params[:task][:assigned_member_id] = nil
      end
	    params.require(:task).permit(:title, :mandate_id, :department_id, :deadline_string, :assigned_member_id)
  	end

end