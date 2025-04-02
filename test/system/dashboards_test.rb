require "application_system_test_case"

class DashboardsTest < ApplicationSystemTestCase
  setup do
  @school = School.create!(name: "Test School", address: "123 Test St", has_paid: 1, subscription_end: 1.year.from_now)

  @admin = User.create!(
    first_name: "Admin",
    last_name: "User",
    email_address: "admin@test.com",
    role: "admin",
    approved: true,
    school_id: @school.id,
    personal_email: "admin@personal.com",
    password: "password123"
  )

  @admin.update(
    password: "password123"
  )

  @teacher = User.create!(
    email_address: "teacher@test.com",
    password: "password123",
    role: "teacher",
    approved: true,
    school_id: @school.id,
    personal_email: "teacher@personal.com",
    first_name: "Teacher",
    last_name: "User"
  )
  end

  test "visiting the index" do
    login_as(@admin)
    assert_selector "h2", text: "Dashboard"
  end

  test "click on students" do
    login_as(@admin)

    click_on "Total Students"
    assert_selector "h2", text: "Students"
  end

  test "click on teachers as admin" do
    login_as(@admin)

    click_on "Total Teachers"
    assert_selector "h2", text: "Teachers"
  end
end
