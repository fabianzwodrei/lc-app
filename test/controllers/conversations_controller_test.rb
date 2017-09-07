require "test_helper"
class ConversationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :martha
  end

  ## show

  test "can see a department conversation when member of that department" do
    get conversation_url(conversations(:sprechstunde_conversation).id)
    assert_response :success
  end

  test "cannot see a department conversation when not member of that department" do
    get conversation_url(conversations(:interneorga_conversation).id)
    assert_response :forbidden
  end

  test 'can see a course conversation and the forum link when attendance permitted' do
    attend :course_permission_required, true
    get event_url(courses(:course_permission_required)) + ".htmlp"
    assert_select FORUM_LINK
    get conversation_url(conversations(:course_conversation).id)
    assert_response :ok
  end

  test 'cannot see a course conversation and the forum link when attendance not permitted' do
    attend :course_permission_required
    get event_url(courses(:course_permission_required)) + ".htmlp"
    assert_select FORUM_LINK, false
    get conversation_url(conversations(:course_conversation).id)
    assert_response :forbidden
  end

  test 'cannot see a course conversation and the forum link when not attended' do
    get event_url(courses(:course_permission_required)) + ".htmlp"
    assert_select FORUM_LINK, false
    get conversation_url(conversations(:course_conversation).id)
    assert_response :forbidden
  end

  test 'can see a course conversation as member of Schulungen' do
    sign_in :sonja
    get event_url(courses(:course_permission_required)) + ".htmlp"
    assert_select FORUM_LINK
    get conversation_url(conversations(:course_conversation).id)
    assert_response :ok
    get courses_url
    assert_select FORUM_LINK
  end

  ## create

  test "can create message on conversation" do
    send_msg
    get conversation_url(conversations(:sprechstunde_conversation).id)
    assert_select FIRST_MSG, MSG_TEXT
  end

  test "cannot create message on conversation" do
    with :tina do
      send_msg
    end
    get conversation_url(conversations(:sprechstunde_conversation).id)
    assert_select FIRST_MSG, false, 'should not exist'
  end

  test "can create private conversation" do
    with :sonja do
      create_or_start_private_conversation_with :martha, :sonja
    end

    get conversations_url
    assert_select "#conversations h5:first", "sonja surname"
  end

  private

  FIRST_MSG = '.message:first-child .message-content'
  FORUM_LINK = '#course_5 .forum_link'
  MSG_TEXT = 'abc'

  def send_msg
    post conversation_messages_url(conversations(:sprechstunde_conversation).id),
         params: { message: {text: MSG_TEXT }}
  end

  def create_or_start_private_conversation_with member1, member2
    post conversations_url(), params: { conversation: { member1_id: members(member1).id, member2_id: members(member2).id, private: true }}
  end
end