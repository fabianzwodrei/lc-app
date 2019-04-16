class MembersController < ApplicationController
	
	load_and_authorize_resource

	def suggest
		if params[:query]
      partial_clause = Member.unlocked.where("(LOWER(first_name) LIKE '%#{params[:query].downcase}%' OR LOWER(last_name) LIKE '%#{params[:query].downcase}%')")
         .limit(9)
         .select(:id, :first_name, :last_name)
      if params[:mandate]
        @member = partial_clause.joins(:mandates)
                      .where(mandates: { id: params[:mandate] })
      else
        @member = partial_clause
      end
		end
	end

	def prepare_list
		@query   = "(LOWER(first_name) LIKE '%#{params[:query].downcase}%' OR LOWER(last_name) LIKE '%#{params[:query].downcase}%')" unless params[:query].blank?
		@qualification_cached_filter = "qualification_cached = #{params[:qualification_cached].to_i}" unless params[:qualification_cached].blank?
		
		@size    = controller_path.classify.constantize.where(@query).where(@qualification_cached_filter).count
		@limit   = 20
		@offset  = params[:offset].blank? ? 0 : params[:offset].to_i

		
		@members = Member.where(@query).where(@qualification_cached_filter).limit(@limit).offset(@offset)
	end
 	
	def index
		prepare_list
	end

	def attendances
	end

	def annotations
		prepare_list
	end

	def public
		@members = []
		if @filter = params[:filter]
			@members = Member.unlocked.in_department @filter
		else
			@members = Member.unlocked
		end
	end

	def index_rights
	end

	def new
		@member = Member.new
	end

	def departments
	end

	def lock
		msg = ""
		if @member.locked_at
			@member.unlock_access!
			msg = 'Mitglied wurde aktiviert'
		else
			@member.lock_access!
			msg = 'Mitglied wurde deaktiviert'
		end
		redirect_to edit_member_path(@member), notice: msg
	end

	def edit
	end

	def edit_right
	end

	def show
		@department_id ||= params[:department_id].to_i
		# @member = Member.find(params[:id])
	end

	def qualification
		@member = Member.find(params[:id])
	end

	def update_password
		@member = Member.find(current_member.id)
		if @member.update(member_params)
	      # Sign in the member by passing validation in case their password changed
	      bypass_sign_in(@member)
	      redirect_to edit_member_path(@member), notice: 'Passwort wurde erfolgreich geändert.'
	  else
	  	render "edit"
	  end
	end

	def update_right
		departments = params[:member][:departments].reject { |d| d.empty? }
		@member.update({departments:departments})
		if @department_id
			redirect_to members_rights_path(params:{department_id:@department_id}), notice: "Die Berechtigungen wurden erfolgreicht aktualisiert."
		else
			redirect_to edit_member_path(@member), notice: "Die Berechtigungen wurden erfolgreicht aktualisiert."
		end
	end

	def update
		params[:member][:departments] = nil # this has to be done exclusively via update_right
		@member.avatar = nil if params[:member][:delete_avatar]

		return render :edit unless _update
		redirect_back(
				notice: 'Mitglied wurde erfolgreich aktualisiert.',
				fallback_location: root_path
				) if _update
	end

	def create
		@member = Member.new(member_params)
		@member.fee_payment = FeePayment.create(paid:false)
		@member.annotation = Annotation.create
		
		return render action: 'new' unless @member.save
		if request.format == :json
			render :json => @member, include: [:annotation]
		else
			redirect_to members_path, notice: 'Mitglied wurde erfolgreich hinzugefügt.'
		end
	end

	private

  def _update
		params[:member][:password].blank? ? @member.update_without_password(member_params) : @member.update(member_params)
	end

	def member_params
		p = params.require(:member).permit(:email, :first_name, :last_name, :course_of_studies, :semester_count, :hobbies, :entry_date, :password, :password_confirmation, :languages, :available, :did_confirm_privacy_clause, :avatar, :phone, :public_infos, :subscribed_unread_conversations_email, :departments => [])
		p[:departments].reject!(&:blank?) if p[:departments]
		p
	end
end