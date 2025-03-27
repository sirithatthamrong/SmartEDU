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
    scheme = params[:base_color_scheme]
    if scheme == "light"
      params[:color_theme].merge!(
        base_100_color: "#ffffff",
        base_200_color: "#f8f8f8",
        base_300_color: "#f0f0f0",
        base_500_color: "#d0d0d0",
        base_content_color: "#00182A",
        neutral_color: "#6b8a9e",
        neutral_content_color: "#f3faff"

      )
    elsif scheme == "dark"
      params[:color_theme].merge!(
        base_100_color: "#1e1e1e",
        base_200_color: "#2a2a2a",
        base_300_color: "#333333",
        base_500_color: "#4e4e4e",
        base_content_color: "#ffffff",
        neutral_color: "#3d3d3d",
        neutral_content_color: "#f3faff"
      )
    end

    if @color_theme.update(color_theme_params)
      flash.now[:notice] = "Theme updated successfully."
      render :edit, status: :ok
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
      accent_color: "#FFEAD2",
      base_100_color: "#FFFFFF",
      base_200_color: "#F8F8F8",
      base_300_color: "#F0F0F0",
      base_500_color: "#d0d0d0",
      base_content_color: "#00182A",
      neutral_color: "#6B8A9E",
      neutral_content_color: "#F3FAFF"
    }
  end

  def color_theme_params
    params.require(:color_theme).permit(
      :primary_color,
      :secondary_color,
      :accent_color,
      :base_100_color,
      :base_200_color,
      :base_300_color,
      :base_500_color,
      :base_content_color,
      :neutral_color,
      :neutral_content_color
      )
  end

  def authorize_admin_or_principal!
    unless current_user.admin? || current_user.principal?
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
