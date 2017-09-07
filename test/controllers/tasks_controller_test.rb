require "test_helper" 
class TasksControllerTest < ActionDispatch::IntegrationTest

	test "member can create task on dashboard" do
		sign_in :tim
		create_task "AufgabeEins"
		visit_dashboard
		assert_select "h6.task_title:first", "AufgabeEins"
	end

	test "member cannot edit task of other member" do
		sign_in :sabine

		with :tim do
	      apply_for_mandate
	    end
	    with :sabine do
	      approve_latest_assignment
	    end
	    with :tim do
			create_task_for_mandate "Mandatsaufgabe1", mandates(:mandate_1).id
		end

		visit_mandate_path
		assert_select "h6.task_title:first", "Mandatsaufgabe1"

   		assert_select "#tasks_listing li:first a.edit_task", false, "edit link should not be there"
   		assert_select "#tasks_listing li:first input.close_task", false, "close-input should not be there" 
	end

	test "member cannot visit edit path for tasks of other members" do
		sign_in :sabine

		with :tim do
	      apply_for_mandate
	    end
	    with :sabine do
	      approve_latest_assignment
	    end
	    with :tim do
			create_task_for_mandate "Mandatsaufgabe1", mandates(:mandate_1).id
		end

		visit_edit_task_path mandates(:mandate_1).tasks.last.id
		assert_equal 403, status
	end

	test "member can add private task on dashboard, it wont appear on mandate pagee" do
		sign_in :tim

		with :tim do
	      apply_for_mandate
	    end
	    with :sabine do
	      approve_latest_assignment
	    end

		create_task "Private Aufgabe1"

		visit_dashboard
		assert_select "h6.task_title:first", "Private Aufgabe1"

		visit_mandate_path
		assert_select "h6.task_title:first", 0
	end

	private
		def create_task title
			post tasks_url(params: {task: { title: title}})
		end
		def create_task_for_mandate title, mandate_id
			post tasks_url(params: {task: { title: title, mandate_id: mandate_id }})
		end
end