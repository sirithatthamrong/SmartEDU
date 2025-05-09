require "application_system_test_case"

class StudentsTest < ApplicationSystemTestCase
  setup do
    @school = School.create!(name: "Test School", address: "123 Main St", has_paid: 1)
    @school.update(subscription_end: 1.month.from_now)

    @principal = User.create!(
      first_name: "Admin",
      last_name: "Test",
      personal_email: "principal_#{SecureRandom.hex(4)}@gmail.com",
      role: "admin",
      password: "password123",
      approved: true,
      school_id: @school.id
    )

    @principal.update(
      password: "password123"
    )

    @classroom = Classroom.create!(
      grade_level: 5,
      class_id: "MATH101",
      school_id: @school.id
    )
    @classroom2 = Classroom.create!(
      grade_level: 6,
      class_id: "MATH102",
      school_id: @school.id
    )
    @user = User.create!(
      first_name: "Test",
      last_name: "Student",
      personal_email: "test_student_#{SecureRandom.hex(4)}@gmail.com",
      role: "student",
      password: "securepassword",
      school_id: @school.id
    )
    @student = Student.create!(
      name: "#{@user.first_name} #{@user.last_name}",
      grade: @classroom.grade_level,
      classroom_id: @classroom.id,
      student_email_address: @user.email_address,
      parent_email_address: "parenttest@example.com"
    )
    login_as(@principal)
  end

  test "visiting the index" do
    visit students_url
    assert_selector "h2", text: "Students"
  end

  test "should create student" do
    visit students_url
    click_on "Create New Student"

    fill_in "First Name", with: "Hello"
    fill_in "Last Name", with: "World"
    select @classroom.grade_level.to_s, from: "grade-select"
    select @classroom.class_id, from: "classroom-select"
    fill_in "Personal Email Address", with: "student#{SecureRandom.hex(4)}@example.com"
    fill_in "Parent Email Address", with: "parenttest@example.com"
    click_on "Create Student"
    assert_text "Hello World was successfully created."
  end

  test "should update student" do
    visit student_url(@student)
    click_on "Edit", match: :first
    fill_in "First Name", with: "Edited"
    fill_in "Last Name", with: "StudentName"
    select @classroom.grade_level.to_s, from: "grade-select"
    select @classroom.class_id, from: "classroom-select"
    fill_in "Personal Email Address", with: "#{SecureRandom.hex(8)}@example.com"
    fill_in "Parent Email Address", with: @student.parent_email_address

    click_on "Update Student"
    assert_text "Edited StudentName was successfully updated."
    click_on "Back"
  end

  test "should archive student (destroy)" do
    visit student_url(@student)

    puts "Before clicking Archive - is_active: #{@student.is_active}"

    click_on "Archive", match: :first
    click_on "Yes, Archive", match: :first
    sleep 5 # Allow time for the database update

    @student.reload
    puts "After clicking Archive - is_active: #{@student.is_active}"

    assert_equal false, @student.is_active, "Student should be archived but is still active"
  end
end
