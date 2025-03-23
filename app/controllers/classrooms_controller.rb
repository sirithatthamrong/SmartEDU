class ClassroomsController < ApplicationController
  before_action :set_classroom, only: [ :show, :grading ]
  before_action :authorize_admin_or_teacher_or_principal!

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
    # @classroom is already set by before_action
    # Use classroom association to filter students instead of directly by school_id
    @grades = Student.joins(:classroom)
                     .where(classrooms: { school_id: current_user.school_id })
                     .distinct
                     .where.not(grade: nil)
                     .pluck(:grade)
                     .compact
                     .sort
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
end
