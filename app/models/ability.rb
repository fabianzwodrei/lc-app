class Ability
  include CanCan::Ability

  def initialize(member, department_id=nil)
    member ||= Member.new

    can :interact_with, :window if not member.id

    unless member.new_record?

#  - - - - - NORMAL MEMBERS
      can :apply, Assignment
      can :unapply, Assignment
      can [:public, :index], Member

      can [:update,:edit,:update_password], Member do |m|
        member.id==m.id
      end

      # Events
        # General Events
        # index-Event will affect inheriting classes like Courses, Consultations
        can [:export, :show, :calendar], Event 
        can :index, Event 
        cannot :index, Consultation
        cannot :index, Course

        
        can :create, Event if member.departments.any? # will affect inheriting classes like Courses, Consultations
        cannot :create, Course unless member.departments.include? SCHULUNGEN
        cannot :create, Consultation unless member.departments.include? SPRECHSTUNDE

        can [:edit, :destroy, :update, :email, :add_member, :remove_member], Event do |event|
          member.departments.include? event.department_id
        end
        can :attend, Event do |event|
          event.attendance_possible? member
        end
        can :unattend, Event do |event|
          event.unattendance_possible? member
        end

        can [:permit, :unpermit], Attendance do |attendance|
          attendance.authorized_by member
        end

#  - - - - - RESSORTS 

      if member.departments.include? ORGANISATION
        can :manage, Member
      end

      if member.departments.include? MANDATSVERWALTUNG
        can :manage, Inquiry
        can :manage, Mandate
        can :manage, Assignment
        can :manage, Annotation
        can [:annotations, :qualification], Member
      end

      if member.departments.include? SPRECHSTUNDE
        can :manage, Consultation
        can [:index], Attendance
        can [:new,:create], Mandate
        can [:new,:create], Inquiry
        can :show, Person # necessary for client_select
        can [:qualifications, :qualification], Member
      end

      if member.departments.include? FINANZEN
        can :manage, FeePayment
      end

      if member.departments.include? SCHULUNGEN
        can :manage, Course
        can :award, Attendance
        can :unaward, Attendance
      end

      # Member
      can :suggest, Member
      cannot :index_rights, Member
      cannot :edit_right, Member
      cannot :update_right, Member

      if member.departments.include? VORSTAND
        can :update_right, Member do |m| m.id == member.id end
        can :edit_right, Member do |m| m.id == member.id end
        can :departments, Member
      end
      if member.departments.include? RECHTE
        can :index_rights, Member
        can :update_right, Member do |m| m.id != member.id end
        can :edit_right, Member do |m| m.id != member.id end
      end

      can :show, Member do |m|
        m.email == member.email
      end

      

      # Person
      can :public_index, Person
      can :suggest, Person
      can :index, Person if member.departments.include? department_id
      can [:show, :new, :create, :edit, :update, :destroy], Person do |p|
        p.editable_by member
      end
      can [:edit, :update], Person do |p| 
        p.editable_through_mandate_by member
      end
      can :show, Person, public: true

      # Mandates
      can :public_index, Mandate

      can [:show, :get_attachment], Mandate do |mandate|
        mandate.is_assigned_to member
      end

      can [:request_review], Mandate do |mandate|
        mandate.is_assigned_to member and member.full_qualified
      end
      
      # Conversations
      can [:read, :create], Conversation do |conversation|
        conversation.is_open_for member or can? :manage, Course
      end

      can [:create, :get_attachment, :thread], Message do |message|
        message.conversation.is_open_for member
      end

      #  Projects
      can :archived, Project
      can [:new, :create], Project if member.departments.count > 0
      can :show, Project do |project| project.seen_by? member end
      can [:edit, :update, :add_member, :remove_member], Project do |project| project.edited_by? member end

      # Tasks
      can :create, Task
      can [:manage, :close, :done], Task, member_id: member.id
      can :close, Task, assigned_member_id: member.id

      # Docs and Bibliographies
      can :index, Bibliography
      can :read, Bibliography do |bib|
        if bib.department_id
          member.departments.include? bib.department_id
        else
          true
        end
      end
      can :create, Bibliography if member.departments.any?
      can [:edit, :update, :destroy], Bibliography do |bib|
         bib.editable_by member
      end

      can [:read, :get_attachment, :thumbnail], Document if can? :read, Bibliography
      can [:create, :edit, :destroy, :update], Document if can? :create, Bibliography
    end
  end
end
