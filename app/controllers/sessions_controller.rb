class SessionsController < ApplicationController
    allow_unauthenticated_access only: %i[new create]
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

    def new
      # this is intended empty, use for rendering notices and alerts.
    end

    def show
      redirect_to new_session_path
    end

    def create
      user = User.find_by(email_address: params[:email_address].strip.downcase)
      if user
        Rails.logger.debug "User found: #{user.inspect}"
        authenticate_user(user)
      else
        handle_invalid_credentials
      end
    end

    def destroy
      terminate_session
      redirect_to new_session_path
    end



    def authenticate_user(user)
      if user.authenticate(params[:password])
        create_session_for(user)
        handle_authenticated_user(user)
      else
        Rails.logger.debug "Password authentication failed for user: #{user.email_address}"
        handle_invalid_credentials
      end
    end

    def create_session_for(user)
      session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      start_new_session_for(user)
    end

    def handle_authenticated_user(user)
      if user.approved?
        handle_approved_user(user)
      else
        flash[:error] = "Your account is pending approval."
        render :new, status: 422
      end
    end

    def handle_approved_user(user)
      if user.school.has_paid && user.school.subscription_active?
        redirect_to home_index_path
      else
        handle_unpaid_subscription(user)
      end
    end

    def handle_unpaid_subscription(user)
      if user.role == "admin" || user.role == "principal"
        redirect_to renew_payments_url
      else
        flash[:error] = "Please contact your school admin for access."
        render :new, status: 422
      end
    end

    def handle_invalid_credentials
      flash[:error] = "Invalid email or password."
      render :new, status: 422
    end
end
