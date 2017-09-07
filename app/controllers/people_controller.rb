class PeopleController < ApplicationController

  include PeopleHelper

  load_and_authorize_resource

  def public_index
    @public = true
    @people = Person.where(public: true)
    render "people/public/index"
  end

  def suggest
    render_suggest(params)
  end

  def index
    @people = Person.where(department_id: params[:department_id]) 
  end

  def new
    @person.department_id = params[:department_id] if params[:department_id]
  end

  def edit
  end

  def show
  end

  def destroy
    @department_id = @person.department_id
    if @person.destroy
      redirect_to people_path({department_id:@department_id}), notice: 'Kontakt wurde erfolgreich gelöscht.'
    else
      render action: 'edit'
    end
  end

  def update
    @origin = params[:origin] unless params[:origin].blank?
    
    if @person.update person_params
      if @origin
        redirect_to @origin
      else
        redirect_to person_path(@person), notice: 'Person wurde erfolgreich aktualisiert.'
      end
    else
      render action: 'edit'
    end
  end

  def create
    if @person.save
      redirect_to person_path(@person), notice: 'Person wurde erfolgreich hinzugefügt.'
    else
      render action: 'new'
    end
  end

  private

  ## used from javascript in _suggest
  def render_suggest(params)
    if params[:query] and params[:role]
      @people = Person.where("(LOWER(first_name) LIKE '%#{params[:query].downcase}%' OR LOWER(last_name) LIKE '%#{params[:query].downcase}%') AND role = '#{params[:role]}'")
        .limit(9)
        .select(:id, :first_name, :last_name)
    end
  end

  def person_params
    params[:person][:public] = false if is_client
    params.require(:person).
        permit(permitted_client_attrs)
  end

  def is_client
    (@person && (@person.role == 'client')) || (params[:person][:role] && (params[:person][:role] == 'client'))
  end

  def load_people(department_id,roles)
    Person
      .where("role = 'contact' AND department_id = '#{department_id}' AND role in (?)",roles)
      .or(Person.where("role != 'contact' and role in (?)",roles))
      .order('last_name ASC')
    # .limit(50)
    # we can not have a limit unless pagination is implemented
    # otherwise there would be no change to see all records
  end
end