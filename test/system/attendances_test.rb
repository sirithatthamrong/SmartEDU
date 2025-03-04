require "application_system_test_case"

class AttendancesTest < ApplicationSystemTestCase
  setup do
    @attendance = Attendance.first
    @student = Student.find(@attendance.student_id)
    login
  end

  test "visiting the index" do
    visit attendances_url
    assert_selector "h2 span", text: "Attendances"
  end

  test "should create attendance" do
    visit new_attendance_url
    within "tr[data-content='#{@student.name}']" do
      click_on "Check-in"
    end
  end
end
