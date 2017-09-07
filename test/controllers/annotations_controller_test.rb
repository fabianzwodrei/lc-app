require "test_helper"
class AnnotationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :sabine
  end
    
  test "can see annotation" do
    get edit_annotation_url(annotations(:sabines_annotation).id)
    assert_response :success
  end

  test "cannot see annotation" do
    sign_in :tina
    get edit_annotation_url(annotations(:sabines_annotation).id)
    assert_response :forbidden
  end

  test "can change annotation" do
    change_and_compare
  end

  test "cannot update annotation" do
    sign_in :tina
    put_change
    assert_response :forbidden

  end

  test "can see annotation of a new member" do
    response = nil
    with :tina do
      response = add_member 'tom@mitglieder.com'
    end
    get edit_annotation_url(response['annotation']['id'])
    assert_response :success
  end

  private

  def put_change
    put annotation_url(annotations(:sabines_annotation).id), params: { annotation: { text: 'new' }}
  end



  def change_and_compare(expect_changed = true)
    put_change
    assert_response :redirect

    with :sabine do
      expected = 'new'
      expected = annotations(:sabines_annotation).text unless expect_changed
      get edit_annotation_url(annotations(:sabines_annotation).id)
      assert_select '#annotation_text', expected
    end
  end

end