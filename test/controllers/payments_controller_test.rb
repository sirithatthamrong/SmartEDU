require "test_helper"
require "stripe"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
  end

  test "should create payment" do
    payment_intent = Stripe::PaymentIntent.construct_from({
                                                            id: "pi_123",
                                                            amount: 1000,
                                                            currency: "thb",
                                                            status: "succeeded"
                                                          })

    Stripe::PaymentIntent.stub(:create, payment_intent) do
      payment_params = {
        first_name: "John",
        last_name: "Doe",
        amount: 10,
        payment_method_id: "pm_card_visa",
        email: "smth@gmail.com",
        school_name: "Mahidol",
        schoolAddress: "123 Main St",
        personal_email: "smth@gmail.com"
      }
      post payments_url, params: payment_params

      assert_response :success
      assert_equal "success", JSON.parse(response.body)["status"]
    end
  end
end
