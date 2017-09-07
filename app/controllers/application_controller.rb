class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	before_action :authenticate_member!
  before_action :ensure_privacy_clause_confirmation
	alias_method :current_user, :current_member

  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end

  private

  def current_ability
    @department_id = params[:department_id].to_i if params[:department_id]
    @current_ability ||= Ability.new(current_member, @department_id)
  end

  def current_permission
    @current_permission ||= ::Permissions.permission_for(current_member)
  end

  def ensure_privacy_clause_confirmation
    return unless current_member
    unless current_member.did_confirm_privacy_clause 
      unless [edit_member_path(current_member), member_path(current_member), destroy_member_session_path].include? request.path
        redirect_to edit_member_path(current_member), alert: 'Die Einverständniserklärung zum Datenschutz fehlt! Unten im Profil-Formular kann sie gegeben werden.'
      end
    end
  end
end
