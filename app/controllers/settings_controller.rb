class SettingsController < ApplicationController
  before_action :authenticated?
  before_action :authorize_admin_or_principal!
  before_action :set_color_theme, only: [:show, :edit, :update]

  def show
    # Nothing else needed here — @color_theme already set
  end

  def edit
    # Also uses @color_theme from before_action
  end

  def update
    if @color_theme.update(color_theme_params)
      redirect_to settings_path, notice: "Theme updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_color_theme
    @school = current_user.school
    @color_theme = @school.color_theme || @school.create_color_theme(default_colors)
  end

  def default_colors
    {
      primary_color: "#8294C4",
      secondary_color: "#ACB1D6",
      tertiary_color: "#DBDFEA",
      accent_color: "#FFEAD2",
    }
  end

  def color_theme_params
    params.require(:color_theme).permit(
      :primary_color,
      :secondary_color,
      :tertiary_color,
      :accent_color,
    )
  end

  def authorize_admin_or_principal!
    unless current_user.admin? || current_user.principal?
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
