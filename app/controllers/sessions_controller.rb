class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def show
    redirect_to new_session_path
  end

  def create
    user = User.find_by(email_address: params[:email_address].strip.downcase)

    if user&.authenticate(params[:password])
      if user.approved?
        start_new_session_for(user)
        if user.school.has_paid
        redirect_to after_authentication_url
        else
          redirect_to payments_new_path, notice: "Please pay to continue."
        end
      else
        flash[:notice] = "Your account is pending approval."
        redirect_to root_url
      end
    else
      flash[:error] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
