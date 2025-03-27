class ClassroomsController < ApplicationController
  before_action :set_classroom, only: [ :show, :grading ]
  before_action :authorize_admin_or_teacher_or_principal!


  def new
    @classroom = Classroom.new
    @available_teachers = User.where(school_id: current_user.school_id)
                              .where(role: "teacher")
  end

  def view
    @classroom = Classroom.find_by(id: params[:id])

    # Handle the case when classroom is not found
    if @classroom.nil?
      flash[:alert] = "Classroom not found"
      redirect_to manage_classrooms_path and return
    end

    # Now it's safe to use @classroom.id
    @students = Student.where(classroom_id: @classroom.id)
                       .order(:name)
    @homerooms = Homeroom.where(classroom_id: @classroom.id)
                         .includes(:teacher_user)
                         .index_by(&:classroom_id)
  end

  def destroy
    classroom = Classroom.find_by(id: params[:id], school_id: current_user.school_id)

    if classroom
      # Delete all dependent records
      classroom.students.each do |student|
        Attendance.where(student_id: student.id).delete_all
        TeacherStudentRelationship.where(student_id: student.id).delete_all
        student.teacher_student_relationships.destroy_all
        student.destroy
      end

      Homeroom.where(classroom_id: classroom.id).delete_all

      classroom.destroy
      render json: { success: "Classroom deleted" }, status: :ok
    else
      render json: { error: "Classroom not found" }, status: :not_found
    end
  end




  def create
  @classroom = Classroom.new(classroom_params)
  @classroom.school_id = current_user.school_id

  if Classroom.exists?(class_id: @classroom.class_id, school_id: @classroom.school_id)
    flash[:error] = "Grade Classroom already exists."
    @available_teachers = User.where(school_id: current_user.school_id)
                              .where(role: "teacher")
    redirect_to manage_classrooms_path
    nil
    # render :new
  elsif @classroom.save
    # Create the homeroom association with the teacher
    Homeroom.create!(
      classroom_id: @classroom.id,
      teacher_id: params[:classroom][:teacher_id]
    )

    redirect_to manage_classrooms_path, notice: "Classroom was successfully created."
  else
    @available_teachers = User.where(school_id: current_user.school_id)
                              .where(role: "teacher")
    render :new
  end
end
  def manage
    # get all the classrooms for the current user's school
    @get_all_classrooms = Classroom.where(school_id: current_user.school_id)
    @homerooms = Homeroom.where(classroom_id: @get_all_classrooms.pluck(:id))
                         .includes(:teacher_user)
                         .index_by(&:classroom_id)
    @student_counts = Student.where(classroom_id: @get_all_classrooms.pluck(:id)).group(:classroom_id).count
  end
  def index
      first_classroom = Classroom.find_by(school_id: current_user.school_id)

      if first_classroom
        redirect_to grading_classroom_path(first_classroom) and return
      end
    @classrooms = Classroom.where(school_id: current_user.school_id)
    end
  def show
    # @classroom is already set by before_action
    # If students don't have school_id, we filter by classroom instead
    @students = @classroom.students.where(grade: @classroom.grade_level).order(:name)
  end

  def grading
    # Get unique grade levels from classrooms in the current school
    @grades = Classroom.where(school_id: current_user.school_id)
                       .distinct
                       .pluck(:grade_level)
                       .compact
                       .sort

    Rails.logger.debug "Grades: #{@grades.inspect}"

    # If you need caching, use the last updated classroom
    @last_update = Classroom.where(school_id: current_user.school_id).maximum(:updated_at)
    fresh_when(etag: @last_update) if @last_update
  end

  def by_grade
    @grade = params[:grade].to_i

    if @grade.blank?
      flash[:alert] = "Grade is missing."
      redirect_to classrooms_path and return
    end

    # Filter classrooms by grade and current user's school
    @classrooms = Classroom.where(school_id: current_user.school_id, grade_level: @grade).order(:class_id)

    if @classrooms.empty?
      flash[:notice] = "No classrooms found for grade #{@grade} in your school."
      redirect_to classrooms_path and return
    end

    Rails.logger.debug "DEBUG: @grade = #{@grade}"
    Rails.logger.debug "DEBUG: @classrooms count = #{@classrooms.count}"
    Rails.logger.debug "DEBUG: School ID = #{current_user.school_id}"
  end



  private

  def set_classroom
    @classroom = Classroom.find_by(id: params[:id], school_id: current_user.school_id)

    if @classroom.nil?
      flash[:alert] = "Classroom not found or you don't have access to this classroom."
      redirect_to classrooms_path and return
    end
  end

  def authorize_admin_or_teacher_or_principal!
    unless current_user&.admin? || current_user&.teacher? || current_user&.principal?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
  def classroom_params
    params.require(:classroom).permit(:grade_level, :class_id)
  end
end
