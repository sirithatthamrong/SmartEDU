require "test_helper"
require "stripe"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
  end

  test "should render success page" do
    sign_in
    get success_payments_url
    assert_response :success
  end

  test "should redirect if school subscription has ended" do
    school = School.first
    school.update(subscription_end: 1.day.ago)

    payment_params = {
      first_name: "John",
      last_name: "Doe",
      amount: 10,
      payment_method_id: "pm_card_visa",
      email: "smth@gmail.com",
      school_name: school.name,
      schoolAddress: school.address,
      personal_email: "smth@gmail.com"
    }

    post payments_url, params: payment_params

    assert_redirected_to new_payment_path
  end

test "should get the payment path when sign in if the school has not paid" do
  school = School.first
  school.update(subscription_end: 1.day.ago)
  user = User.create!(
    first_name: "Test",
    last_name: "User",
    email_address: "test@example.com",
    personal_email: "test@personal.com",
    role: "teacher",
    approved: true,
    school_id: school.id,
    password: "password123"
  )

  sign_in_with_parameter(user)
  get home_index_url
  assert_redirected_to new_payment_path
  assert_equal "Your school subscription has expired. Please renew.", flash[:alert]
end
end
