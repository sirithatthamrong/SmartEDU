class UsersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @pending_users = User.pending_in_school(current_user.school_id)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def approve
    @user = User.find(params[:id])

    unless @user.school_id == current_user.school_id
      redirect_to users_path, alert: "You can only approve users from your school."
      return
    end

    ActiveRecord::Base.transaction do
      if @user.update(approved: true)
        if @user.teacher?
          principal = User.find_by(school_id: @user.school_id, role: "principal")

          if principal
            PrincipalTeacherRelationship.create!(principal_id: principal.id, teacher_id: @user.id)
          else
            Rails.logger.warn "WARNING: No principal found for school_id=#{@user.school_id}. Teacher approved without assignment."
          end
        end

        respond_to do |format|
          format.html { redirect_to users_path, notice: "#{@user.email_address} has been approved." }
          format.js
        end
      else
        Rails.logger.error "ERROR: Failed to approve user: #{@user.errors.full_messages.join(', ')}"
        respond_to do |format|
          format.html { redirect_to users_path, alert: "Failed to approve user." }
          format.js { render js: "alert('Failed to approve user: #{@user.errors.full_messages.join(', ')}')" }
        end
      end
    end
  end

  def cancel
    @user = User.find(params[:id])

    if @user.destroy
      respond_to do |format|
        format.html { redirect_to users_path, notice: "#{@user.email_address} has been removed." }
        format.js
      end
    else
      Rails.logger.error "ERROR: Failed to remove user: #{@user.errors.full_messages.join(', ')}"
      respond_to do |format|
        format.html { redirect_to users_path, alert: "Failed to remove user." }
        format.js { render js: "alert('Failed to remove user: #{@user.errors.full_messages.join(', ')}')" }
      end
    end
  end

  private

  def authenticate_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.can_manage_teachers?
  end
end
