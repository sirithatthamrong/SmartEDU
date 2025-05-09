require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attendance = Attendance.find_by!(student_id: 1) # Adjust based on your seed data
    sign_in
  end

  test "should get index" do
    get attendances_url
    assert_response :success
  end

  test "should create attendance" do
    assert_changes("Attendance.count") do
      post attendances_url, params: { student_id: @attendance.student_id }
      puts @response.body
    end
  end

  test "should show attendance" do
    get attendance_url(@attendance)
    assert_response :success
  end

  test "should get edit" do
    get edit_attendance_url(@attendance)
    assert_response :success
  end

  test "should update attendance" do
    patch attendance_url(@attendance), params: { attendance: { student_id: @attendance.student_id, timestamp: Time.current, user_id: @attendance.user_id } }
    assert_redirected_to attendance_url(@attendance)
  end

  test "should destroy attendance" do
    assert_difference("Attendance.count", -1) do
      delete attendance_url(@attendance)
    end
    assert_redirected_to attendances_url
  end
end
