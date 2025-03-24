class SettingsController < ApplicationController
  before_action :authenticated?
  before_action :authorize_admin_or_principal!

  def show
    @school = current_user.school
  end

  def update
    @school = current_user.school
    if @school.update(school_params)
      redirect_to settings_path, notice: "Theme updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def school_params
    params.require(:school).permit(:primary_color, :secondary_color, :accent_color, :neutral_color)
  end

  def authorize_admin_or_principal!
    unless current_user.admin? || current_user.principal?
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
