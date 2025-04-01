require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = School.create!(name: "Test School", address: "123 Main St")
    @principal = User.create!(
      first_name: "Principal",
      last_name: "Test",
      personal_email: "principal_#{ SecureRandom.hex(4) }@gmail.com",
      role: "principal",
      password: "password123",
      school_id: @school.id
    )
    sign_in_with_parameter(@principal)
  end

  test "should get show" do
    get settings_show_url
    assert_response :success
  end

  test "should get edit" do
    get edit_settings_path
    assert_response :success
  end
end
