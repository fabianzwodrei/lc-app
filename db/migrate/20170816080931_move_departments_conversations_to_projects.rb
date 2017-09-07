class MoveDepartmentsConversationsToProjects < ActiveRecord::Migration[5.0]
  def change
  	d_conversations = Conversation.where.not(department_id: nil)
  	for d_c in d_conversations
  		pr = Project.create departments: [d_c.department_id], title: "Ex Interne Kommunikation"
  		d_c.project_id = pr.id
  		d_c.department_id = nil
  		d_c.save
  	end
  end
end
