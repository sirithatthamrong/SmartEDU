require "test_helper"

class StudentPrivilegesTest < ActionDispatch::IntegrationTest
  setup do
    @eiei_school = School.create!(name: "Test School", address: "123 Main St", has_paid: 1, subscription_end: 1.year.from_now)

    @user = User.create!(
      first_name: "Test#{SecureRandom.hex(2)}",
      last_name: "Student#{SecureRandom.hex(2)}",
      personal_email: "test_student_#{SecureRandom.hex(4)}@gmail.com",
      role: "student",
      password: "password123",
      approved: true,
      school_id: @eiei_school.id
    )
  end

  test "should get profile" do
    sign_in_with_parameter(@user)
    get profile_path
    assert_response :success
  end
end
