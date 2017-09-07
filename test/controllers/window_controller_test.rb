require "test_helper"
class WindowControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sabine
    post mandates_url,
         params: { mandate: { title: 'window_test_mandate' }}
    get edit_mandate_url Mandate.maximum(:id)
    @access_code = (css_select '.access_code').text
    @confirmation_code = (css_select '.confirmation_code').text
    sign_out
  end

  test "see mandate detail" do
    verify_detail @access_code, 'window_test_mandate'
  end

  test 'do not see mandate detail of unknown' do
    verify_detail 'unkown', false
  end

  test 'can post message' do
    post window_message_url,
         params: { message: { content: 'abc' },
                   confirmation_code: @confirmation_code,
                   access_code: @access_code
         }
    verify_msg 'abc'
  end

  test 'cannot post message with wrong confirmation code' do
    post_msg_without_code
    verify_msg false
  end

  test 'retain msg content' do
    post_msg_without_code
    assert_equal flash[:msg_content], 'abc'
  end

  private

    def post_msg_without_code
      post window_message_url,
           params: { message: { content: 'abc' },
                     confirmation_code: 'no',
                     access_code: @access_code
           }
    end

    def verify_detail(access_code,exp)
      get "/window/detail/#{access_code}"
      assert_select '#title', exp
    end

    def verify_msg(exp)
      sign_in :sabine
      get mandate_url Mandate.maximum(:id)
      assert_select '.message-content', exp
    end
end