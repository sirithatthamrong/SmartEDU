class ProfileController < ApplicationController
  before_action :authorize_user!

  def show
    @user = current_user
    @student = Student.find_by(student_email_address: @user.email_address) if @user.student?
    render "profiles/show"
  end

  private

  def authorize_user!
    unless current_user.student? || current_user.teacher? || current_user.admin? || current_user.principal?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
