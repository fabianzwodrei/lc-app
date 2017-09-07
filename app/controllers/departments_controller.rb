class DepartmentsController < ApplicationController
  def show
    @department_id = params[:id].to_i
  end
end