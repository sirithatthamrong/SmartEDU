class ClassroomsController < ApplicationController
  before_action :set_classroom, only: %i[show grading]
  before_action :authorize_admin_or_teacher_or_principal!

  def new
    @classroom = Classroom.new
    @available_teachers = fetch_available_teachers
  end

  def view
    @classroom = Classroom.find_by(id: params[:id])
    unless @classroom
      flash[:alert] = "Classroom not found"
      return redirect_to manage_classrooms_path
    end

    @students = Student.where(classroom_id: @classroom.id).order(:name)
    @homerooms = Homeroom.includes(:teacher_user)
                         .where(classroom_id: @classroom.id)
                         .index_by(&:classroom_id)
  end

  def destroy
    classroom = fetch_classroom_by_id

    if classroom
      if classroom.students.exists?
        flash[:errors] = "Classroom cannot be deleted because it has students. Please reassign them first."
        return redirect_to manage_classrooms_path
      end

      Homeroom.where(classroom_id: classroom.id).delete_all
      classroom.destroy!
      redirect_to manage_classrooms_path, notice: "Classroom was successfully deleted."
    else
      render json: { error: "Classroom not found" }, status: :not_found
    end
  end

  def create
    @classroom = Classroom.new(classroom_params.merge(school_id: current_user.school_id))

    if Classroom.exists?(class_id: @classroom.class_id, school_id: @classroom.school_id)
      flash[:error] = "Grade Classroom already exists."
      return redirect_to manage_classrooms_path
    end

    if @classroom.save
      Homeroom.create!(classroom_id: @classroom.id, teacher_id: params[:classroom][:teacher_id])
      redirect_to manage_classrooms_path, notice: "Classroom was successfully created."
    else
      @available_teachers = fetch_available_teachers
      render :new
    end
  end

  def manage
    @get_all_classrooms = fetch_classrooms_by_school

    if @get_all_classrooms.present?
      classroom_ids = @get_all_classrooms.ids

      @homerooms = Homeroom.includes(:teacher_user)
                           .where(classroom_id: classroom_ids)
                           .index_by(&:classroom_id)

      @student_counts = Student.where(classroom_id: classroom_ids)
                               .group(:classroom_id)
                               .count
    else
      @homerooms = {}
      @student_counts = {}
    end
  end

  def index
    first_classroom = fetch_classrooms_by_school.first

    return redirect_to grading_classroom_path(first_classroom) if first_classroom

    @classrooms = fetch_classrooms_by_school
  end

  def show
    @students = Student.where(grade: @classroom.grade_level).order(:name)
  end

  def grading
    @grades = fetch_classrooms_by_school.distinct
                                        .pluck(:grade_level)
                                        .compact
                                        .sort

    @last_update = fetch_classrooms_by_school.maximum(:updated_at)
    fresh_when(etag: @last_update) if @last_update
  end

  def by_grade
    @grade = params[:grade].to_i

    if @grade.zero?
      flash[:alert] = "Grade is missing."
      return redirect_to classrooms_path
    end

    @classrooms = Classroom.where(school_id: current_user.school_id, grade_level: @grade)
                           .order(:class_id)

    if @classrooms.empty?
      flash[:notice] = "No classrooms found for grade #{@grade} in your school."
      return redirect_to classrooms_path
    end

    Rails.logger.debug { "DEBUG: @grade = #{@grade}, @classrooms count = #{@classrooms.count}, School ID = #{current_user.school_id}" }
  end

  def update
    @classroom = fetch_classroom_by_id

    unless @classroom
      flash[:alert] = "Classroom not found or you don't have access."
      return redirect_to manage_classrooms_path
    end

    if Classroom.where(school_id: current_user.school_id, class_id: @classroom.class_id)
                .where.not(id: @classroom.id)
                .exists?
      flash[:error] = "Grade Classroom already exists."
      @available_teachers = fetch_available_teachers
      return render :edit
    end

    if @classroom.update(classroom_params)
      homeroom = Homeroom.find_or_initialize_by(classroom_id: @classroom.id)
      homeroom.update!(teacher_id: params[:classroom][:teacher_id])

      redirect_to manage_classrooms_path, notice: "Classroom was successfully updated."
    else
      @available_teachers = fetch_available_teachers
      render :edit
    end
  end

  def edit
    @classroom = fetch_classroom_by_id

    unless @classroom
      flash[:alert] = "Classroom not found or you don't have access."
      return redirect_to manage_classrooms_path
    end

    @available_teachers = fetch_available_teachers
  end

  private

  def fetch_available_teachers
    User.where(school_id: current_user.school_id, role: "teacher")
  end

  def fetch_classroom_by_id
    Classroom.find_by(id: params[:id], school_id: current_user.school_id)
  end

  def fetch_classrooms_by_school
    Classroom.where(school_id: current_user.school_id)
  end

  def set_classroom
    @classroom = fetch_classroom_by_id

    unless @classroom
      flash[:alert] = "Classroom not found or you don't have access."
      redirect_to classrooms_path
    end
  end

  def authorize_admin_or_teacher_or_principal!
    unless current_user&.admin? || current_user&.teacher? || current_user&.principal?
      redirect_to home_index_url, alert: "You are not authorized to access this page."
    end
  end

  def classroom_params
    params.require(:classroom).permit(:grade_level, :class_id)
  end
end
