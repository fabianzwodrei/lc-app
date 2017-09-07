class InquiriesController < ApplicationController

  include PeopleHelper

  load_and_authorize_resource

  def show
    @inquiry.client = Person.new unless @inquiry.client
  end

  def index
    if params['client']
      @inquiries, @client_name = _index_handle_client params['client']
    elsif params['from']
      @inquiries, @count, @from = _index_handle_from params['from']
    else
      @inquiries = _index_handle_default
    end
  end

  def new
    @inquiry = Inquiry.new
    @department_id = params[:department_id]
  end

  def update
    if @inquiry.update(inquiry_params)
      redirect_to inquiries_path, notice: 'Sachstandsanfrage wurde erfolgreich aktualisiert.'
    else
      render action: 'show'
    end
  end

  def create
    @inquiry.simple = true
    @inquiry.done = false
    if @inquiry.save
      if request.format == :json
        render :json => @inquiry
      else
        notice = 'Sachstandsanfrage wurde erfolgreich hinzugefügt.'
        return redirect_to root_path, notice: notice if params[:department_id].to_i == SPRECHSTUNDE
        redirect_to inquiries_path, notice: notice
      end
    else
      render action: 'new'
    end
  end

  private
    def inquiry_params
      set_client_attrs(params.require(:inquiry).permit(
          :title, :member_id, :description, :done, :client_id, client_attributes: permitted_client_attrs
      ))
    end

    def _index_handle_client(params_client)
      client = Person.find params_client
      client_name = client.name if client
      return (Inquiry.for_client client), client_name
    end

    def _index_handle_from(params_from)
      inquiries = Inquiry.done.offset(params_from).limit(Rails.configuration.x.page_items)
      return inquiries,
          Inquiry.done.count,
          params_from.to_i
    end

    def _index_handle_default
      Inquiry.undone
    end
end