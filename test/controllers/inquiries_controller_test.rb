require "test_helper"
class InquiriesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sabine
  end

  test "see inquiries overview" do
    get inquiries_url
    assert_response :success
  end

  test "cannot see inquiries overview" do
    sign_in :tina
    get inquiries_url
    assert_response :forbidden
  end

  test "post new inquiry" do
    create_one false
    get inquiries_url
    assert_select "#inquiries_list div:first-child div div", "title"
  end

  test "don't list it when its done" do
    create_one true
    set_done
    get inquiries_url
    assert_select "#inquiries_list div:first-child", false
  end

  test "post new inquiry list it via from when its done" do
    create_one true
    set_done
    get inquiries_url+'?from=0'
    assert_select "#inquiries_list div:first-child div div", "title"
  end

  test "post new inquiry, list it via client" do
    create_one false
    get inquiries_url+'?client='+Person.maximum(:id).to_s
    assert_select "#inquiries_list div:first-child div div", "title"
  end

  test "post new inquiry, show inquiries for clients" do
    create_one true # using the client query param also shows closed inquiries are shown
    get inquiries_url+'?client='+Person.maximum(:id).to_s
    assert_select "#inquiries_list div:first-child div div", "title"
    get inquiries_url+'?client=1'
    assert_select "#inquiries_list div:first-child", false
  end


  ## new

  test 'can see new form' do
    get new_inquiry_url
    assert_response :ok
  end

  test 'can see new form as member of sprechstunde' do
    with :martha do
      get new_inquiry_url
      assert_response :ok
    end
  end

  test 'cannot see new form' do
    with :tina do
      get new_inquiry_url
      assert_response :forbidden
    end
  end

  ## create

  test 'can create one' do
    create_one false
  end

  test 'can create one as member of sprechstunde' do
    with :martha do
      create_one false
    end
  end

  test 'cannot create one' do
    with :tina do
      create_one false, :forbidden
    end
  end

  test 'can create client with inquiry' do
    post inquiries_url,
         params: { inquiry: { title: 'inquiry_title',
                              client_attributes: {first_name: "a", last_name:"b", email: "a@b.com" } }}
    verify_see_contact(0,'a b',true)
  end

  test "create new inquiry validation err" do
    create_one_invalid
    assert_select "#error_explanation p", /1\sFehler.*/
  end

  test "create new inquiry validation err retain form values" do
    create_one_invalid
    assert_select "#inquiry_title" do
      assert_select "[value=?]", "title"
    end
    assert_select "#inquiry_client_attributes_first_name" do
      assert_select "[value=?]", "first-name"
    end
  end

  private

    def create_one(done, expected_response = :redirect)
      post inquiries_url, params:
          { inquiry: { title: "title", done: done, simple: true,
                       client_attributes: { first_name: "first-name", last_name: "last-name", email: "email@email.com", role: "client"} } }
      assert_response expected_response
    end

    def set_done
      patch inquiry_url(Inquiry.maximum(:id)), params:
          { inquiry: { done: "true" }}
    end

    def create_one_invalid
      post inquiries_url, params:
          { inquiry: { title: "title",
                       client_attributes: { first_name: "first-name", last_name: "last-name", role: "client"} } }
    end
end