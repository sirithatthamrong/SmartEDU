class SettingsController < ApplicationController
  WHITE       = "#ffffff".freeze
  GRAY_100    = "#f0f0f0".freeze
  GRAY_200    = "#d0d0d0".freeze
  GRAY_BLUE = "#1f2937".freeze

  before_action :authenticated?
  before_action :authorize_admin_or_principal!
  before_action :set_color_theme, only: [ :show, :edit, :update ]

  def show
    # This action is intentionally left blank.
  end

  def edit
    # This action is intentionally left blank.
  end

  def update
    params[:color_theme][:theme_name] = "mytheme" if params[:color_theme][:theme_name] == "custom"
    selected_theme = params[:color_theme][:theme_name]

    case selected_theme
    when "light"
      params[:color_theme].merge!(
        primary_color: "#570df8",
        secondary_color: "#f000b8",
        accent_color: "#37cdbe",
        accent_content: "#163835",
        base_100_color: WHITE,
        base_200_color: "#f2f2f2",
        base_300_color: "#e5e6e6",
        base_500_color: GRAY_200,
        base_content_color: GRAY_BLUE,
      )
    when "pastel"
      params[:color_theme].merge!(
        primary_color: "#d1c1d7",
        primary_content_color: "#5e2a8c",
        secondary_color: "#f4c2c2",
        secondary_content_color: "#7d2121",
        accent_color: "#b5ead7",
        accent_content: "#215c42",
        base_100_color: WHITE,
        base_200_color: "#f8f8f8",
        base_300_color: "#f0f0f0",
        base_500_color: GRAY_200,
        base_content_color: GRAY_BLUE
      )
    when "cupcake"
      params[:color_theme].merge!(
        primary_color: "#65c3c8",
        primary_content_color: "#004950",
        secondary_color: "#ef9fbc",
        secondary_content_color: "#49101e",
        accent_color: "#eeaf3a",
        accent_content_color:"3b2300",
        base_100_color: "#faf7f5",
        base_200_color: "#efeae6",
        base_300_color: "#e7e2df",
        base_500_color: "#d6d0cb",
        base_content_color: "#291334"
      )
    when "emerald"
      params[:color_theme].merge!(
        primary_color: "#34d399",
        secondary_color: "#3b82f6",
        accent_color: "#f97316",
        base_100_color: WHITE,
        base_200_color: "#f2f2f2",
        base_300_color: "#e5e6e6",
        base_500_color: GRAY_200,
        base_content_color: GRAY_BLUE
      )
    when "mytheme"
      params[:color_theme].merge!(
        base_100_color: WHITE,
        base_200_color: "#F8F8F7",
        base_300_color: GRAY_100,
        base_500_color: GRAY_200,
        base_content_color: "#00182B",
        neutral_color: "#6b8a9e",
        neutral_content_color: "#f3faff"
      )
    else
      raise "Unexpected theme selected: #{selected_theme}"
    end

    if @color_theme.update(color_theme_params)
      flash[:notice] = "Theme updated successfully."
      redirect_to edit_settings_path
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
      theme_name: "mytheme",
      primary_color: "#8294C4",
      primary_content_color: "#F3FAFF",
      secondary_color: "#ACB1D6",
      secondary_content_color: "#F1FBFB",
      accent_color: "#FFEAD2",
      accent_content_color: "#00182A",
      base_100_color: WHITE,
      base_200_color: "#F8F8F8",
      base_300_color: GRAY_100,
      base_500_color: GRAY_200,
      base_content_color: "#00182A",
      neutral_color: "#6B8A9E",
      neutral_content_color: "#F3FAFF"
    }
  end

  def color_theme_params
    params.require(:color_theme).permit(
      :theme_name,
      :primary_color,
      :primary_content_color,
      :secondary_color,
      :secondary_content_color,
      :accent_color,
      :accent_content_color,
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
    redirect_to root_path, alert: "Not authorized" unless current_user.admin? || current_user.principal?
  end
end
