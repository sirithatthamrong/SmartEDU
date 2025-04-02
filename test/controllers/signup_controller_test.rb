require "test_helper"

class SignupControllerTest < ActionDispatch::IntegrationTest
  setup do
    @eiei_school = School.create!(name: "Test School", address: "123 Main St")
  end

  test "should get new" do
    get new_signup_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post signup_index_url, params: { user: { first_name: "Test",
                                          last_name: "User",
                                          personal_email: "test@example.com",
                                          role: "teacher",
                                          school_id: @eiei_school.id } }
    end
  end
end
