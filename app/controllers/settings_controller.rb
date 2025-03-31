class SettingsController < ApplicationController
  WHITE       = "#ffffff".freeze
  GRAY_100    = "#f0f0f0".freeze
  GRAY_200    = "#d0d0d0".freeze

  before_action :authenticated?
  before_action :authorize_admin_or_principal!
  before_action :set_color_theme, only: [:show, :edit, :update]

  def show;
    # This method is intentionally left empty
  end
  def edit;
    # This method is intentionally left empty
  end

  def update
    selected_theme = params[:color_theme][:theme_name]

    # Built-in themes: only save theme_name and overwrite just core colors
    case selected_theme
    when "light"
      params[:color_theme].merge!(
        primary_color: "#570df8",
        secondary_color: "#f000b7",
        accent_color: "#37cdbf",
        base_100_color: WHITE,
        base_200_color: "#f8f8f8",
        base_300_color: GRAY_100,
        base_500_color: GRAY_200,
        base_content_color: "#00182a"
      )
    when "dark"
      params[:color_theme].merge!(
        primary_color: "#793ef9",
        secondary_color: "#f000b8",
        accent_color: "#37cdbe",
        base_100_color: "#1e1e1e",
        base_200_color: "#2a2a2a",
        base_300_color: "#333333",
        base_500_color: "#4e4e4e",
        base_content_color: WHITE
      )
    when "pastel"
      params[:color_theme].merge!(
        primary_color: "#d1c1d7",
        secondary_color: "#f4c2c2",
        accent_color: "#b5ead7",
        base_100_color: WHITE,
        base_200_color: "#f8f8f8",
        base_300_color: GRAY_100,
        base_500_color: GRAY_200,
        base_content_color: "#00182a"
      )
    when "custom"
      # Custom colors will be handled below — this is here to satisfy static analysis tools like SonarQube.
    else
      raise "Unexpected theme selected: #{selected_theme}"
    end

    # For custom themes, we handle the base color scheme
    if selected_theme == "custom"
      case params[:base_color_scheme]
      when "light"
        params[:color_theme].merge!(
          base_100_color: WHITE,
          base_200_color: "#F8F8F7",
          base_300_color: GRAY_100,
          base_500_color: GRAY_200,
          base_content_color: "#00182B",
          neutral_color: "#6b8a9e",
          neutral_content_color: "#f3faff"
        )
      when "dark"
        params[:color_theme].merge!(
          base_100_color: "#1e1e1e",
          base_200_color: "#2a2a2a",
          base_300_color: "#333333",
          base_500_color: "#4e4e4e",
          base_content_color: WHITE,
          neutral_color: "#3d3d3d",
          neutral_content_color: "#f3faff"
        )
      else
        raise "Unexpected base color scheme selected: #{params[:base_color_scheme]}"
      end
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
