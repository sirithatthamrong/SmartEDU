require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = School.create!(name: "Test School", address: "123 Main St")
    @principal = User.create!(
      first_name: "Principal",
      last_name: "Test",
      personal_email: "principal_#{SecureRandom.hex(4)}@gmail.com",
      role: "principal",
      password: "password123",
      school_id: @school.id
    )
    sign_in_with_parameter(@principal)

    setup do
      @school = School.create!(name: "Test School", address: "123 Main St")
      @color_theme = ColorTheme.create!(
        theme_name: "mytheme",
        primary_color: "#8294C4",
        primary_content_color: "#F3FAFF",
        secondary_color: "#ACB1D6",
        secondary_content_color: "#F1FBFB",
        accent_color: "#FFEAD2",
        accent_content_color: "#00182A",
        base_100_color: "#FFFFFF",
        base_200_color: "#F8F8F8",
        base_300_color: "#E0E0E0",
        base_500_color: "#B0B0B0",
        base_content_color: "#00182A",
        neutral_color: "#6B8A9E",
        neutral_content_color: "#F3FAFF"
      )
      @school.color_theme = @color_theme
      @school.save!
    end
  end


  test "should get show" do
    get settings_show_url
    assert_response :success
  end

  test "should get edit" do
    get edit_settings_path
    assert_response :success
  end

  test "should update settings" do
    patch settings_path, params: {
      color_theme: {
        theme_name: "light"
      },
      base_color_scheme: "light"
    }

    assert_redirected_to edit_settings_path
    follow_redirect!
    assert_response :success
  end
end
