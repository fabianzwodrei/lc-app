require "test_helper"
class FeePaymentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in :leif
  end

  test "can see people listing" do
    get fee_payments_url
    assert_response :success
  end

  test "cannot see people listing" do
    sign_in :tina
    get fee_payments_url
    assert_response :forbidden
  end

  test "can see finance data" do
    get fee_payment_url(fee_payments(:tinas_payment).id)
    assert_response :success
  end

  test "cannot see finance data" do
    sign_in :tina
    get fee_payment_url(fee_payments(:tinas_payment).id)
    assert_response :forbidden
  end

  test "can update finance data" do
    change_and_compare
  end

  test "cannot update finance data" do
    sign_in :tina
    change_and_compare false
  end

  ## index

  test 'see in index that tina has not yet paid' do
    get fee_payments_url
    assert_select TINAS_PAYMENT+'.member_full_name', 'tina surname'
    assert_select TINAS_PAYMENT+'.text-danger', true
    assert_select TINAS_PAYMENT+'.text-success', false
  end

  test 'see in index that tina has paid' do
    pay_for_tina
    get fee_payments_url
    assert_select TINAS_PAYMENT+'.member_full_name', 'tina surname'
    assert_select TINAS_PAYMENT+'.text-success', true
    assert_select TINAS_PAYMENT+'.text-danger', false
  end

  test 'do see tina in unpaid index when tina has not yet paid' do
    verify_tina_in_open_listing
  end

  test 'do not see tina in unpaid index when tina has paid' do
    pay_for_tina
    verify_tina_in_open_listing false
  end

  ## reset_all

  test 'do not see reset_all page' do
    get reset_all_fee_payments_path
    assert_response :ok
  end

  test 'do see reset_all page' do
    sign_in :tina
    get reset_all_fee_payments_path
    assert_response :forbidden
  end

  test 'cannot perform reset all' do
    pay_for_tina
    sign_in :tina
    delete reset_all_fee_payments_url
    assert_response :forbidden
    verify_tina_in_open_listing false
  end

  test 'can perform reset all' do
    pay_for_tina
    delete reset_all_fee_payments_url
    assert_equal flash[:notice], 'Die Zahlungsdaten aller Mitglieder wurden erfolgreich zurückgesetzt.'
    verify_tina_in_open_listing
  end


  ## other

  test 'ensure new member has a fee_payment to work with' do
    id = nil
    with :tina do
      id = (add_member "tom@tom.com")['id']
    end
    get fee_payments_url(params:{open: true})
    assert_select "#accordion #member-#{id} .member_full_name", 'Firstname Lastname'
    put fee_payment_url(FeePayment.maximum(:id)),
        params: { fee_payment: { account_details: "new", paid: true }}
    get fee_payments_url(params:{open: true})
    assert_select "#accordion #member-#{id}", false
  end

  private

  TINAS_PAYMENT = '#accordion #member-1 '

  def verify_tina_in_open_listing(should_be_there=true)
    with :leif do
      get fee_payments_url(params:{open: true})
      if should_be_there
        assert_select TINAS_PAYMENT+'.member_full_name', 'tina surname'
      else
        assert_select TINAS_PAYMENT+'.member_full_name', false
      end
    end
  end

  def pay_for_tina
    put fee_payment_url(fee_payments(:tinas_payment).id),
        params: { fee_payment: { account_details: "new", paid: true }}
  end

  def change_and_compare(expect_changed = true)
    put fee_payment_url(fee_payments(:leifs_payment).id),
        params: { fee_payment: { account_details: "new" }}

    with :leif do
      expected = 'new'
      expected = fee_payments(:leifs_payment).account_details unless expect_changed
      get fee_payment_url(fee_payments(:leifs_payment).id)
      assert_select '#fee_payment_account_details', expected
    end
  end

end