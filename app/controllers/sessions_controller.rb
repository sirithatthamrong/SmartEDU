class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    # This is the login page
  end

  def show
    redirect_to new_session_path
  end

  def create
    user = User.find_by(email_address: params[:email_address].strip.downcase)
    if user
      Rails.logger.debug "User found: #{user.inspect}"

      if user.authenticate(params[:password])
        session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
        start_new_session_for(user)
        if user.approved?
          if user.school.has_paid && user.school.subscription_active?
              redirect_to home_index_path
          else
            if user.role == "admin" || user.role == "principal"
              flash[:alert] = "Your school subscription has expired. Please renew."
              redirect_to new_payment_path
            else
              flash[:alert] = "Your school subscription has expired. Please contact your admin."
              redirect_to root_url
            end
          end
        else
          flash[:notice] = "Your account is pending approval."
          redirect_to root_url
        end
      else
        flash[:error] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    else
      flash[:error] = "Invalid username or password."
      render :new, status: :unprocessable_entity
    end
  end
  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
