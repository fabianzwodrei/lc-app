class HomeController < ApplicationController	
	def index
		@vacant_mandates = Mandate.vacant
		@tasks = Task.undone.by_member_and_assignd_to current_member
		@infoboards = Project.where(use_for_infoboard: true)
		@projects = current_member.projects.active
		@public_mode = true
		@unread_conversations = current_member.unread_conversations
		
	end
end