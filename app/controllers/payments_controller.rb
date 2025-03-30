class PaymentsController < ApplicationController
  allow_unauthenticated_access only: %i[new create success cancel]

  def new
    @user = current_user || User.new
    @school = current_user&.school
    @current_tier = @school&.school_tier&.tier == "Premium" ? 350 : 200
    if @school && @school.subscription_end.present? && @school.subscription_end < Time.current
      flash.now[:notice] = "Your school subscription has expired. Please renew."
    end
  end


  def renew
    @user = current_user || User.new
    @school = current_user&.school
    @current_tier = @school&.school_tier&.tier == "Premium" ? 350 : 200
    if @school && @school.subscription_end.present? && @school.subscription_end < Time.current
      flash.now[:notice] = "Your school subscription has expired. Please renew."
    end
    render :new
  end

  def create
    school = School.find_by(name: params[:school_name])
    if school && school.subscription_end.present? &&
      school.subscription_end < Time.current &&
      params[:renew] != "true"
      redirect_to new_payment_path, alert: "School subscription has expired. Please renew."
      return
    end

    disable_login_credentials_callback

    ActiveRecord::Base.transaction do
      school = create_or_update_school
      @user = find_or_create_user(school)
      payment = process_payment(@user)

      update_school_subscription(school, payment)

      setup_session(payment, @user)
      send_receipt(payment)

      render json: { status: "success", payment: payment }, status: 200
    end

    send_credentials_email if @user&.persisted? && !current_user
    enable_login_credentials_callback

  rescue Stripe::StripeError => e
    handle_stripe_error(e)
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e)
  end

  def success
    @payment = Payment.find_by(id: session[:last_payment_id])
    session.delete(:last_payment_id)

    if @payment
      @school_tier = @payment.user.school.school_tier.tier
      if @school_tier == "Premium"
        @school_tier = "Premium"
      else
        @school_tier = "Basic"
      end
    end
  end

  def cancel
    redirect_to root_path, alert: "Payment cancelled."
  end

  private

  def update_school_subscription(school, payment)
    if params[:renew] == "true" && school.subscription_end&.future?
      new_end_date = school.subscription_end + 1.year
    else
      new_end_date = Time.zone.now + 1.year
    end

    # Update the school's subscription end date
    school.update(
      subscription_end: new_end_date,
      has_paid: 1
    )
    payment.update(
      subscription_start: Time.zone.now,
      subscription_end: new_end_date
    )
  end

  def create_or_update_school
    if current_user&.school && params[:renew] == "true"
      school = current_user.school
      school.update(tier: params[:tier].to_i == 200 ? 1 : 2)
    else
      school = School.find_or_create_by(name: params[:school_name]) do |s|
        s.address = params[:schoolAddress]
        s.has_paid = 1
        s.tier = params[:tier].to_i == 200 ? 1 : 2
      end
      if school.persisted?
        school.update(tier: params[:tier].to_i == 200 ? 1 : 2)
      end
    end
    school_tier = SchoolTier.find_or_create_by(school_id: school.id)
    school_tier.update(tier: params[:tier].to_i == 350 ? "Premium" : "Basic")

    school
  end

  def find_or_create_user(school)
    if current_user
      current_user.update!(approved: true)
      return current_user
    end

    existing_user = User.find_by(personal_email: params[:email])

    if existing_user
      existing_user.update!(approved: true)
      existing_user
    else
      User.create!(
        first_name: params[:first_name],
        last_name: params[:last_name],
        personal_email: params[:email],
        role: "admin",
        school_id: school.id,
        approved: true
      )
    end
  end

  def process_payment(user)
    payment_intent = create_stripe_payment_intent

    Payment.create!(
      amount: params[:amount].to_i,
      status: "succeeded",
      user_id: user.id,
      stripe_payment_intent_id: payment_intent.id,
      last_name: params[:last_name],
      first_name: params[:first_name],
      email: params[:email],
      subscription_start: Time.zone.now,
      subscription_end: Time.zone.now + 1.year
    )
  end

  def create_stripe_payment_intent
    Stripe::PaymentIntent.create({
                                   amount: params[:amount].to_i * 100,
                                   currency: "thb",
                                   payment_method: params[:payment_method_id],
                                   confirmation_method: "manual",
                                   confirm: true,
                                   return_url: success_payments_url
                                 })
  end

  def setup_session(payment, user)
    session[:last_payment_id] = payment.id
    start_new_session_for user unless current_user
  end

  def send_receipt(payment)
    PaymentMailer.receipt_email(payment).deliver_now
  end

  def send_credentials_email
    password = @user.instance_variable_get(:@plain_password)
    UserMailer.send_login_credentials(@user, password).deliver_now if password
  end

  def handle_stripe_error(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def handle_record_invalid(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def disable_login_credentials_callback
    User.skip_callback(:create, :after, :send_login_credentials) if User._create_callbacks.map(&:filter).include?(:send_login_credentials)
  end

  def enable_login_credentials_callback
    User.set_callback(:create, :after, :send_login_credentials) if User.method_defined?(:send_login_credentials)
  end
end
