class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
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

  def new
    @student = Student.new
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)
    @classrooms = Classroom.where(school_id: current_user.school_id)
    Rails.logger.debug "Grades: #{@grades.inspect}"
    Rails.logger.debug "Classrooms: #{@classrooms.inspect}"
  end

  def edit
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)
    @classrooms = Classroom.where(school_id: current_user.school_id)
    Rails.logger.debug "Grades: #{@grades.inspect}"
    Rails.logger.debug "Classrooms: #{@classrooms.inspect}"
  end

  def create
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)
    @classrooms = Classroom.where(school_id: current_user.school_id)

    @student = Student.new(student_params)
    @user = User.new(user_params)

    classroom = Classroom.find_by(id: raw_student_params[:classroom_id], school_id: current_user.school_id)

    if classroom.nil?
      @student.errors.add(:classroom_id, "must belong to the selected school and grade")
      flash.now[:error] = "Classroom not found or does not belong to this school."
      Rails.logger.debug "Error: Classroom not found for school_id=#{current_user.school_id}"
      render :new, status: :unprocessable_entity and return
    end

    success = ActiveRecord::Base.transaction do
      @user.assign_attributes(
        first_name: user_params[:first_name],
        last_name: user_params[:last_name],
        personal_email: user_params[:personal_email],
        role: "student",
        password: SecureRandom.hex(8),
        school_id: current_user.school_id
      )

      unless @user.valid?
        Rails.logger.debug "User creation failed: #{@user.errors.full_messages}"
        flash.now[:errors] = @user.errors.full_messages.map { |msg| "<li>#{msg}</li>" }.join
        raise ActiveRecord::Rollback
      end

      @user.save!

      full_name = "#{@user.first_name} #{@user.last_name}"
      @student.assign_attributes(
        name: full_name,
        grade: student_params[:grade],
        classroom_id: classroom.id,
        student_email_address: @user.email_address,
        parent_email_address: student_params[:parent_email_address]
      )

      unless @student.valid?
        Rails.logger.debug "Student creation failed: #{@student.errors.full_messages}"
        flash.now[:error] = @student.errors.full_messages.to_sentence
        raise ActiveRecord::Rollback
      end

      @student.save!
      Rails.logger.debug "Student successfully created: #{@student.inspect}"

      true # If everything is successful
    end

    if success
      Rails.logger.debug "Redirecting to student: #{student_url(@student)}"
      redirect_to @student, notice: "#{@student.name} was successfully created."
    else
      Rails.logger.debug "Rendering new student form due to failure."
      render :new, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Transaction failed: #{e.message}"
    flash.now[:error] = "Error: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def update
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)
    @classrooms = Classroom.where(school_id: current_user.school_id)

    ActiveRecord::Base.transaction do
      classroom = Classroom.find_by(id: raw_student_params[:classroom_id], school_id: current_user.school_id)

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
end
