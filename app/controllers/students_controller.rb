class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :authorize_admin_or_principal!, except: [:profile]
  before_action :authorize_student!, only: [:profile]
  include Pagy::Backend

  def index
    @classroom = Classroom.find_by(id: params[:classroom_id]) if params[:classroom_id].present?
    @grades = Student.distinct.pluck(:grade).compact.sort
    students_scope = Student.active
    students_scope = students_scope.where(grade: params[:grade]) if params[:grade].present?
    @pagy, @students = pagy(students_scope)
  end

  def show
    @student = Student.kept.find_by(id: params[:id])
    respond_to do |format|
      format.html { render "show" }
      format.json { render json: @student }
    end
  end

def profile
  Rails.logger.debug "Current User Email: #{current_user.email_address}"
  @student = Student.find_by(student_email_address: current_user.email_address)

  if @student.nil?
    Rails.logger.debug "No student found for email: #{current_user.email_address}"
    redirect_to root_path, alert: "Profile not found."
    return
  end

  Rails.logger.debug "Student Found: #{@student.name}"
  render "profile"
end

  # GET /students/new
  def new
    @student = Student.new
  end

  def edit
    # This method is intentionally left empty because the edit functionality
  end

  # POST /students or /students.json
  def create
    classroom = Classroom.find_by(class_id: raw_student_params[:classroom_id]) # Find by class_id (string), not id (integer)

    if classroom.nil?
      flash[:error] = "Classroom not found"
      @student = Student.new(student_params)
      render :new, status: :unprocessable_entity and return
    end

    ActiveRecord::Base.transaction do
      user = User.create!(
        first_name: user_params[:first_name],
        last_name: user_params[:last_name],
        personal_email: user_params[:personal_email],
        role: "student",
        password: SecureRandom.hex(8),
        school_id: current_user.school_id
      )

      full_name = "#{user.first_name} #{user.last_name}"

      @student = Student.create!(
        name: full_name,
        grade: student_params[:grade],
        classroom_id: classroom.id,
        student_email_address: user.email_address,
        parent_email_address: student_params[:parent_email_address]
      )

      respond_to do |format|
        format.html { redirect_to @student, notice: "#{@student.name} was successfully created." }
        format.json { render :show, status: :created, location: @student }
      end
    end

  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    @student = Student.new(student_params)
    render :new, status: :unprocessable_entity
  end

  def update
    ActiveRecord::Base.transaction do
      classroom = Classroom.find_by(class_id: raw_student_params[:classroom_id]) # Find by class_id (string), not id (integer)

      if classroom.nil?
        flash[:error] = "Classroom not found"
        render :edit, status: :unprocessable_entity and return
      end

      user = User.find_by(email_address: @student.student_email_address)

      user.update!(
        first_name: user_params[:first_name],
        last_name: user_params[:last_name],
        personal_email: user_params[:personal_email]
      )

      @student.update!(
        name: "#{user.first_name} #{user.last_name}",
        grade: student_params[:grade],
        classroom_id: classroom.id,
        parent_email_address: student_params[:parent_email_address]
      )
    end

    respond_to do |format|
      format.html { redirect_to @student, notice: "#{@student.name} was successfully updated." }
      format.json { render :show, status: :ok, location: @student }
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    render :edit, status: :unprocessable_entity
  end

  def destroy
    ActiveRecord::Base.transaction do
      @student.update!(is_active: false, discarded_at: Time.current)
      user = User.find_by(email_address: @student.student_email_address)
      user.update!(is_active: false) if user
    end

    respond_to do |format|
      format.html { redirect_to students_path, notice: "#{@student.name} was successfully archived." }
      format.json { head :no_content }
    end
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def raw_student_params
    @raw_student_params ||= params.require(:student).permit(
      :first_name, :last_name, :is_active, :grade, :classroom_id, :personal_email, :parent_email_address
    )
  end

  def student_params
    raw_student_params.slice(:is_active, :grade, :classroom_id, :parent_email_address)
  end

  def user_params
    raw_student_params.slice(:first_name, :last_name, :personal_email) # student_email_address here is actually personal_email
  end
  def authorize_admin_or_principal!
    unless current_user.admin? || current_user.principal?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end

  def authorize_student!
    unless current_user.student?
      redirect_to root_path, alert: "You are not authorized to access this page."
      end
  end
end
