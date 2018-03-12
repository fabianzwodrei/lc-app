require "test_helper"
class MandatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sabine
  end

  ## index

  test "see mandates overview" do
    get mandates_url
    assert_response :success
  end

  test "cannot see mandates overview" do
    sign_in :tina
    get mandates_url
    assert_response :forbidden
  end

  test "can see mandate in mandates overview with supervision filter active" do
    patch mandate_url mandates(:mandate_1).id, params: { mandate: {supervised: false, status: 'active'}}
    get mandates_url(params:{supervision:true})
    assert_select '#mandate-1',true
  end

  test "cannot see mandate in mandates overview with supervision filter active and already a supervised" do
    patch mandate_url mandates(:mandate_1).id, params: { mandate: {supervised: true, status: 'active'}}
    get mandates_url(params:{supervision:true})
    assert_select '#mandate-1',false
  end

  test "cannot see mandate in mandates overview with supervision filter active and status done" do
    patch mandate_url mandates(:mandate_1).id, params: { mandate: {supervised: false, status: 'done'}}
    get mandates_url(params:{supervision:true})
    assert_select '#mandate-1',false
  end

  test 'can approve mandate assigment' do
    with :tim do
      apply_for_mandate
    end

    get mandate_url(mandates(:mandate_1)) + ".htmlp"
    assert_select assignment_actions(1) + ' a', "Zulassen"
  end

  test "can see 'remove assignment' action in mandate controller" do
    assign_and_approve_mandate_for :tim

    get mandate_url(mandates(:mandate_1)) + ".htmlp"
    assert_select assignment_actions(1) + ' a', "Zuweisung entfernen"
  end

  test "can't see any action when mandate closed" do
    assign_and_approve_mandate_for :tim

    action = assignment_actions(1) + ' a'
    get mandate_url(mandates(:mandate_1)) + ".htmlp"
    assert_select action, "Zuweisung entfernen"
    close_mandate
    get mandate_url(mandates(:mandate_1)) + ".htmlp"
    assert_select action, false, "There should be no link to any action"
  end

  test 'notices working properly with approval' do
    with :tim do
      apply_for_mandate
    end
    get mandates_url
    assert_select @@application_notice
    approve_latest_assignment
    get mandates_url
    assert_select @@application_notice, false, "notice should not be there anymore"
    assert_select @@approved_notice
  end

  test 'mandate application notice should not be shown, but notice for lacking approval (when mandate active)' do
    with :tim do
      apply_for_mandate
    end
    get mandates_url
    assert_select @@application_notice
    activate_mandate
    get mandates_url
    assert_select @@application_notice, false, "notice should not be there anymore"
    assert_select @@lacking_approved_member_notice
  end

  test 'no notice should be shown when mandate inactive' do
    with :tim do
      apply_for_mandate
    end
    close_mandate
    visit_closed_mandates
    assert_select @@application_notice, false, 'no notice expected'
    assert_select @@lacking_approved_member_notice, false, 'no notice expected'

    activate_mandate
    approve_latest_assignment
    get mandates_url
    assert_select @@approved_notice
    get mandates_url
    close_mandate
    get mandates_url
    assert_select @@approved_notice, false, 'no notice expected'
  end

  ## public_index

  test 'can not see any action in mandate market' do
    assign_and_approve_mandate_for :tim
    visit_mandate_market
    assert_select '.assignment_action', false, "There should be no link to any action"
  end

  test "can see public mandates overview" do
    sign_in :tina
    get public_mandates_url
    assert_response :success
  end

  test "see one open mandate" do
    sign_in :tim
    verify_mandate_present(:open)
  end

  test "apply for mandate" do
    sign_in :tim
    verify_mandate_present :your_mandates, false
    apply_for_mandate
    verify_mandate_present :your_mandates
  end

  test "mandate must still be available for other user to apply" do
    with :tim do
      apply_for_mandate
    end
    sign_in :sabine
    verify_mandate_present :open
    verify_mandate_present :your_mandates, false
  end

  test "mandate must not be shown when already closed" do
    apply_for_mandate
    verify_mandate_present :your_mandates
    close_mandate
    verify_mandate_present :your_mandates, false
  end

  test 'after first approval other members should still see the apply button' do
    with :tim do
      apply_for_mandate
    end
    approve_latest_assignment
    visit_mandate_market
    assert_select "#mandate_market_open .card:first-child .card-body .btn", 'Bewerben'
  end

  ## new

  test 'can see new mandate view' do
    get new_mandate_url
    assert_response :success
  end

  test 'can see new mandate view as member of sprechstunde' do
    with :martha do
      get new_mandate_url
      assert_response :success
    end
  end

  test 'cannot see new mandate view' do
    sign_in :tina
    get new_mandate_url
    assert_response :forbidden
  end

  ## create

  test 'can create' do
    create
    assert_equal flash[:notice], 'Mandat wurde erfolgreich hinzugefügt.'
  end

  test 'can create as member of sprechstunde' do
    with :martha do
      create
      assert_equal flash[:notice], 'Mandat wurde erfolgreich hinzugefügt.'
    end
  end

  test 'cannot create' do
    with :tina do
      create
      assert_response :forbidden
    end
  end

  test 'can create client with mandate' do
    post mandates_url,
         params: { mandate: { title: 'mandate_title',
                              client_attributes: {first_name: "a", last_name:"b", email: "a@b.com" } }}
    verify_see_contact(0,'a b',true)
  end

  ## edit

  test 'can not edit approved mandate as normal member' do
    assign_and_approve_mandate_for :tim
    sign_in :tim
    visit_edit_mandate_path
    assert_response :forbidden
  end

  test 'can not edit mandate as normal member - not applied, not approved' do
    visit_edit_mandate_path
    assert_response :success
    sign_in :tim
    visit_edit_mandate_path
    assert_response :forbidden
  end

  test 'can not edit mandate as normal member - applied, but not approved' do
    visit_edit_mandate_path
    assert_response :success
    sign_in :tim
    apply_for_mandate
    visit_edit_mandate_path
    assert_response :forbidden
  end

  test 'can see client select link on edit' do
    visit_edit_mandate_path
    assert_select @@select_tab_link, "Ändern"
  end

  ## update

  test 'can not update as regular member if approved' do
    assign_and_approve_mandate_for :tim
    sign_in :tim
    title_value = '#mandate_title[value=?]'
    visit_edit_mandate_path
    assert_response :forbidden
  end

  test 'can update as member of mandatsverwaltung' do
    visit_edit_mandate_path
    title_value = '#mandate_title[value=?]'
    assert_select title_value, mandates(:mandate_1).title
    update_mandate({ title: "changed" })
    visit_edit_mandate_path
    assert_select title_value, 'changed'
  end

  test 'can change client when member of mandatsverwaltung' do
    change_client_and_assert(:hossein)
  end

  test 'can not change client as regular member' do
    assign_and_approve_mandate_for :tim
    sign_in :tim
    # change_client_and_assert(:yasemin)
    update_mandate({ client_id: persons(:hossein,).id })
    assert_response :forbidden
  end

  test 'can not unapply when already approved' do
    assign_and_approve_mandate_for :tim
    sign_in :tim
    unapply_for_mandate
    visit_mandate_path
    assert_response :success
  end

  ## request_review

  test 'can see request-review-button if assigned and full qualified' do
    assign_and_approve_mandate_for :sabine
    update_mandate({ status: "active" })
    visit_mandate_path
    assert_select '.request_review_action a', 'Abnahme anfragen'
  end

  test 'can see & request review button and can request review' do
    assign_and_approve_mandate_for :tim
    update_mandate({ status: "active" })
    sign_in :tim
    visit_mandate_path
    assert_select '.request_review_action a', 'Abnahme anfragen'
    post request_review_mandate_path mandates(:mandate_1).id
    assert flash[:notice].include? "wurde gespeichert"
  end

  test 'cannot see request review action and can not request review if not full qualified' do
    assign_and_approve_mandate_for :svenja
    update_mandate({ status: "active" })
    verify_cannot_request_review :svenja
  end

  test 'cannot see request review action and can not request review if workshop is missing' do
    with :sonja do
      patch course_url(courses(:course_tim_4).id),
            params: { course: { category1: 'lecture', category2: 'A', dates_string: DateTime.now.strftime('%d.%m.%Y - %H:%M').to_s }} # so we have 2 lectures, no workshop
    end

    assign_and_approve_mandate_for :tim
    update_mandate({ status: "active" })
    verify_cannot_request_review :tim
  end

  test 'cannot see request review action and can not request review if lecture A is missing' do
    with :sonja do
      patch course_url(courses(:course_tim_1).id),
            params: { course: { category1: 'lecture', category2: 'B', dates_string: DateTime.now.strftime('%d.%m.%Y - %H:%M').to_s }} # so we have 2 B-lectures 
    end
    assign_and_approve_mandate_for :tim
    update_mandate({ status: "active" })
    verify_cannot_request_review :tim
  end

  private

    def verify_cannot_request_review(member)
      sign_in member
      visit_mandate_path
      assert_select '.request_review_action a', false, '"Abnahme anfragen" should not be visible '
      post request_review_mandate_path mandates(:mandate_1).id
      assert_response :forbidden
    end


    @@select_tab_link = '.search-client-tab-link'

    def create
      post mandates_url,
           params: { mandate: { title: 'mandate_title' }}
    end

    def update_mandate(mandate_object)
      patch mandate_path mandates(:mandate_1).id,
                         params: { mandate: mandate_object }
    end

    def change_client_and_assert(client_name_after)
      update_mandate({ client_id: persons(:hossein,).id })
      visit_edit_mandate_path
      assert_select '#the-client-details .person-name', persons(client_name_after).name
    end

    def visit_mandate_market
      get public_mandates_url
    end

    def title_el(status)
      "#mandate_market_"+status.to_s+" .card:first-child .card-header .mandate-title"
    end

    def verify_mandate_present(mandate_market_list_suffix, presence=true)
      visit_mandate_market
      assert_select(
          title_el(mandate_market_list_suffix),
          presence,
          mandates(:mandate_1).title
      )
    end

    def visit_closed_mandates
      get mandates_url+'?from=0'
    end

    # def mandate_child_nr(nr)
    #   " div:first-child .card-body tr:nth-child(#{nr})"
    # end

    @@first_mandate = '.mandates_listing div div:first-child'

    @@application_notice = @@first_mandate + ' .application-notice'
    @@approved_notice = @@first_mandate + ' .approved-notice'
    @@lacking_approved_member_notice = @@first_mandate + ' .lacking-approved-member-notice'

    # mandate 1 first assignment
    def assignment_actions(child_nr)
      "table tr:nth-child(#{child_nr+1})"
    end
end