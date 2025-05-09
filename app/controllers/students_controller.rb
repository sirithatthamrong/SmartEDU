class StudentsController < ApplicationController
  before_action :set_student, only: %i[ show edit update destroy ]
  skip_before_action :set_student, only: [ :classrooms_by_grade ]
  include Pagy::Backend
  require "csv"

  CSV_HEADER_FIRST_NAME = "First Name"
  CSV_HEADER_LAST_NAME = "Last Name"
  CSV_HEADER_GRADE = "Grade"
  CSV_HEADER_CLASSROOM = "Classroom"
  CSV_HEADER_PERSONAL_EMAIL = "Personal Email Address"
  CSV_HEADER_PARENT_EMAIL = "Parent Email Address"

  CSV_HEADERS = [
    CSV_HEADER_FIRST_NAME,
    CSV_HEADER_LAST_NAME,
    CSV_HEADER_GRADE,
    CSV_HEADER_CLASSROOM,
    CSV_HEADER_PERSONAL_EMAIL,
    CSV_HEADER_PARENT_EMAIL
  ]

  def index
    @classroom = Classroom.find_by(id: params[:classroom_id], school_id: current_user.school_id) if params[:classroom_id].present?
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)

    school_classroom_ids = Classroom.where(school_id: current_user.school_id).pluck(:id)
    students_scope = Student.active.where(classroom_id: school_classroom_ids)
    students_scope = students_scope.where(grade: params[:grade]) if params[:grade].present?
    students_scope = students_scope.where(classroom_id: params[:classroom_id]) if params[:classroom_id].present?

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
    Rails.logger.debug "Grades: #{ @grades.inspect }"
    Rails.logger.debug "Classrooms: #{ @classrooms.inspect }"
  end

  def edit
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)
    @classrooms = Classroom.where(school_id: current_user.school_id)
    Rails.logger.debug "Grades: #{ @grades.inspect }"
    Rails.logger.debug "Classrooms: #{ @classrooms.inspect }"
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
      Rails.logger.debug "Error: Classroom not found for school_id=#{ current_user.school_id }"
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
        flash.now[:errors] = @user.errors.full_messages.map { |msg| "<li>#{msg}</li>" }.join
        raise ActiveRecord::Rollback
      end

      @user.save!

      full_name = "#{@user.first_name} #{ @user.last_name }"
      @student.assign_attributes(
        name: full_name,
        grade: student_params[:grade],
        classroom_id: classroom.id,
        student_email_address: @user.email_address,
        parent_email_address: student_params[:parent_email_address]
      )

      unless @student.valid?
        Rails.logger.debug "Student creation failed: #{ @student.errors.full_messages }"
        flash.now[:error] = @student.errors.full_messages.to_sentence
        raise ActiveRecord::Rollback
      end

      @student.save!
      Rails.logger.debug "Student successfully created: #{ @student.inspect }"

      update_teacher_student_relationships(@student)

      true # If everything is successful
    end

    if success
      Rails.logger.debug "Redirecting to student: #{ student_url(@student) }"
      redirect_to @student, notice: "#{ @student.name } was successfully created."
    else
      Rails.logger.debug "Rendering new student form due to failure."
      render :new, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Transaction failed: #{ e.message }"
    flash.now[:error] = "Error: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def update
    @grades = Classroom.where(school_id: current_user.school_id).distinct.pluck(:grade_level)
    @classrooms = Classroom.where(school_id: current_user.school_id)

    ActiveRecord::Base.transaction do
      classroom = Classroom.find_by(id: raw_student_params[:classroom_id], school_id: current_user.school_id)
      puts "Current user: #{current_user.inspect}"

      if classroom.nil?
        Rails.logger.debug "Error: Classroom not found for school_id=#{current_user.school_id}"
        flash[:error] = "Classroom not found"
        render :edit, status: :unprocessable_entity and return
      end

      user = User.find_by(email_address: @student.student_email_address)
      Rails.logger.debug "Before update - Student: #{@student.inspect}"
      Rails.logger.debug "Before update - User: #{user.inspect}"

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
      Rails.logger.debug "After update - Student: #{@student.reload.inspect}"

      update_teacher_student_relationships(@student)
    end

    respond_to do |format|
      format.html { redirect_to @student, notice: "#{ @student.name } was successfully updated." }
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
      format.html { redirect_to students_path, notice: "#{ @student.name } was successfully archived." }
      format.json { head :no_content }
    end
  end

  def download_csv_template
    example = [ "Example: John", "Doe", "1", "1A", "john.doe@example.com", "parent@example.com" ]

    csv_data = CSV.generate(headers: true) do |csv|
      csv << CSV_HEADERS
      csv << example
    end

    send_data csv_data, filename: "student_import_template.csv", type: "text/csv"
  end

  def import_csv
    file = params[:csv_file]

    unless file&.content_type&.include?("csv")
      redirect_to students_path, alert: "Please upload a valid CSV file." and return
    end

    csv = CSV.parse(file.read, headers: true)

    # 1. Validate column headers
    if csv.headers != CSV_HEADERS
      flash[:error] = "CSV headers must exactly match: #{CSV_HEADERS.join(', ')}"
      redirect_to students_path and return
    end

    failed_rows = []
    imported_students = []

    ActiveRecord::Base.transaction do
      csv.each_with_index do |row, index|
        # 2. Skip the example row (row 2 in this case)
        next if index == 0

        begin
          first_name = row[CSV_HEADER_FIRST_NAME]&.strip
          last_name = row[CSV_HEADER_LAST_NAME]&.strip
          grade = row[CSV_HEADER_GRADE]&.strip
          class_id = row[CSV_HEADER_CLASSROOM]&.strip
          personal_email = row[CSV_HEADER_PERSONAL_EMAIL]&.strip
          parent_email = row[CSV_HEADER_PARENT_EMAIL]&.strip

          classroom = Classroom.find_by(class_id: class_id, grade_level: grade, school_id: current_user.school_id)
          raise "Invalid classroom or grade" if classroom.nil?

          user = User.new(
            first_name: first_name,
            last_name: last_name,
            personal_email: personal_email,
            role: "student",
            school_id: current_user.school_id,
            password: SecureRandom.hex(8)
          )

          unless user.valid?
            raise "User validation failed: #{user.errors.full_messages.join(', ')}"
          end

          user.save!

          student = Student.new(
            name: "#{first_name} #{last_name}",
            grade: grade,
            classroom_id: classroom.id,
            student_email_address: user.email_address,
            parent_email_address: parent_email
          )

          unless student.valid?
            raise "Student validation failed: #{student.errors.full_messages.join(', ')}"
          end

          student.save!
          update_teacher_student_relationships(student)
          imported_students << student

        rescue => e
          failed_rows << { row_number: index + 2, error: e.message } # +2 accounts for 0-based index + header row
          raise ActiveRecord::Rollback
        end
      end
    end

    if failed_rows.empty?
      redirect_to students_path, notice: "Successfully imported #{imported_students.count} students."
    else
      error_list = failed_rows.map { |f| "Row #{f[:row_number]}: #{f[:error]}" }.join("<br>")
      flash[:error] = "Import failed. #{error_list}".html_safe
      redirect_to students_path
    end
  end

  def classrooms_by_grade
    @grade = params[:grade].to_i
    @classrooms = Classroom.where(school_id: current_user.school_id, grade_level: @grade).order(:class_id)
    render json: @classrooms.select(:id, :class_id)
  end

  private

  def update_teacher_student_relationships(student)
    Rails.logger.debug "Updating teacher-student relationships for student_id=#{student.id}"

    homeroom_teacher = Homeroom.find_by(classroom_id: student.classroom_id)&.teacher_id

    if homeroom_teacher
      existing_relationship = TeacherStudentRelationship.find_by(teacher_id: homeroom_teacher, student_id: student.id)

      if existing_relationship
        Rails.logger.debug "Relationship already exists between student #{student.id} and teacher #{homeroom_teacher}"
      else
        TeacherStudentRelationship.create!(teacher_id: homeroom_teacher, student_id: student.id)
        Rails.logger.debug "Assigned student #{student.id} to teacher #{homeroom_teacher}"
      end

      # Remove any old relationships if the student switched classrooms
      TeacherStudentRelationship.where(student_id: student.id).where.not(teacher_id: homeroom_teacher).destroy_all
      Rails.logger.debug "Removed old teacher relationships for student #{student.id}"
    else
      Rails.logger.debug "No homeroom teacher found for classroom_id=#{student.classroom_id}"
    end
  end

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
      redirect_to home_index_url, alert: "You are not authorized to access this page."
    end
  end

  def authorize_student!
    unless current_user.student?
      redirect_to home_index_url, alert: "You are not authorized to access this page."
    end
  end
end
