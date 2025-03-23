require "test_helper"

class ClassroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @eiei_school = School.create!(name: "Eiei School", address: "123 Main St")
    @classroom = Classroom.create!(
      grade_level: 5,
      class_id: 1,
      school_id: @eiei_school.id
    )
    @student = Student.first
    @student2 = Student.second
    sign_in
  end

  test "should get show" do
    get grading_classroom_path(Classroom.first)
    assert_response :success
  end

  test "should get by_grade" do
    get by_grade_classrooms_path(grade: 5)
    assert_response :success
  end
end
