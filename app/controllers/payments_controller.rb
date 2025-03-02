class PaymentsController < ApplicationController
  def create
    Rails.logger.debug("Received params: #{params.inspect}")

    first_name = params[:first_name]
    last_name = params[:last_name]
    amount = params[:amount].to_i
    payment_method_id = params[:payment_method_id]

    begin
      payment_intent = Stripe::PaymentIntent.create({
                                                      amount: amount * 100,
                                                      currency: "thb",
                                                      payment_method: payment_method_id,
                                                      confirmation_method: "manual",
                                                      confirm: true,
                                                      return_url: success_payments_url
                                                    })

      payment = Payment.create(
        amount: amount,
        status: "succeeded",
        user_id: current_user.id,
        stripe_payment_intent_id: payment_intent.id,
        last_name: last_name,
        first_name: first_name
      )


      Rails.logger.info("Payment intent: #{payment_intent}")
      Rails.logger.info("Payment: #{payment}")

      render json: { status: "success", payment: payment }, status: 200

    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      render json: { error: e.message }, status: 500
    rescue StandardError => e
      Rails.logger.error("General error: #{e.message}")
      render json: { error: e.message }, status: 500
    end
  end

  def success
  end

  def cancel
    redirect_to root_path, alert: "Payment cancelled."
  end
end
