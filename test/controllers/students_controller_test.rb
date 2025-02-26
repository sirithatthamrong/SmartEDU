require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = School.create!(name: 'Test School', address: '123 Main St')

    @admin = User.create!(
      first_name: 'Admin',
      last_name: 'Test',
      personal_email: "admin_#{SecureRandom.hex(4)}@gmail.com",
      role: 'admin',
      password: 'securepassword',
      school_id: @school.id
    )

    @classroom = Classroom.create!(
      grade_level: 5,
      class_id: "MATH101", # We are using class_id (string)
      school_id: @school.id
    )

    sign_in(@admin) # Sign in as admin

    @student = Student.first
  end

  test "should create student" do
    user = User.create!(
      first_name: 'John',
      last_name: 'Doe',
      personal_email: "personal_#{SecureRandom.hex(4)}@gmail.com",
      role: 'student',
      password: 'securepassword',
      school_id: @school.id
    )

    assert_difference('Student.count') do
      post students_url, params: { student: {
        first_name: user.first_name,
        last_name: user.last_name,
        grade: @classroom.grade_level,
        classroom_id: @classroom.class_id,  # Pass class_id (not id)
        student_email_address: user.email_address,
        parent_email_address: 'parent.doe@example.com'
      }}
    end

    assert_redirected_to student_url(Student.last)
  end

  test "should show student" do
    get student_url(@student)
    assert_response :success
  end

  test "should get new" do
    get new_student_url
    assert_response :success
  end


  test "should get edit" do
    get edit_student_url(@student)
    assert_response :success
  end

test "should update student" do
  visit edit_student_path(@student)

  fill_in "First name", with: "Jane"
  fill_in "Last name", with: "Doe"
  click_button "Update Student"

  assert_text "Student was successfully updated."
end

  test "archive student after deletion" do
    delete student_url(@student)
    @student.reload
    assert_equal false, @student.is_active?, "Student was not archived"
    assert_redirected_to students_path
    assert_equal "#{@student.name} was archived successfully.", flash[:notice]
  end
end
