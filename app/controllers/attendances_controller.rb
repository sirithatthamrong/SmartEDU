class AttendancesController < ApplicationController
  before_action :set_attendance, only: %i[ show edit update destroy ]
  before_action :authorize_admin_or_principal_or_system_or_teacher!
  include Pagy::Backend
  # GET /attendances or /attendances.json
  def index
    @attendances = Attendance.all
  end

  # GET /attendances/1 or /attendances/1.json
  def show
    # This method is intentionally left empty because the show functionality
    # is handled by the view and does not require any additional logic.
  end

  # GET /attendances/new
  def new
    @q = Student.active.ransack(params[:q])
    @students = @q.result(distinct: true)
    @attendances = Attendance.order(timestamp: :desc).limit(10)
    respond_to do |format|
      format.html # For normal page loads
      format.turbo_stream # For Turbo-powered live updates
    end
  end

  # GET /attendances/1/edit
  def edit
    # This method is intentionally left empty because the edit functionality
    # is handled by the view and does not require any additional logic.
  end

  # POST /attendances or /attendances.json
  def create
    student = Student.find(params[:student_id])

    existing_attendance = Attendance.where(student: student)
                                    .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                                    .first
    if existing_attendance
      existing_attendance.destroy!
      render json: { status: "Destroy!" }, status: :ok
    else
      CheckinService.checkin(student, Current.user)
      render json: { status: "success" }, status: :ok
    end
  end
  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @attendance, notice: "Attendance was successfully updated." }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @attendance.destroy!
    respond_to do |format|
      format.html { redirect_to attendances_path, status: :see_other, notice: "Attendance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def scan_qr
    # This will render app/views/admin/scan_qr.html.erb
  end

  def status
    Rails.logger.info("Checking if student is checked in and authorized")
    Rails.logger.info(params)

    student = Student.find_by(id: params[:attendance_id])

    unless student
      render json: { status: "error", message: "Student not found" }, status: :not_found
      return
    end

    # Check if the student has already checked in today
    checked_in = Attendance.exists?(
      student: student,
      created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    )
    # get the classroom id of the student
    classroom_id = student.classroom_id
    # get the teacher id of the classroom
    homeroom = Homeroom.find_by(classroom_id: classroom_id)
    teacher_id = homeroom&.teacher_id # Safe navigation operator prevents nil errors

    Rails.logger.info("Teacher ID: #{teacher_id}")
    Rails.logger.info("Current User ID: #{current_user&.id}")

    # Check if the user is authorized
    authorized = current_user.system? || (current_user.teacher? && current_user&.id == teacher_id)
    Rails.logger.info("Authorized: #{authorized} Checked In: #{checked_in}")
    render json: { checked_in: checked_in, authorized: authorized }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def attendance_params
    params.require(:attendance).permit(:student_id, :timestamp, :user_id)
  end

  def authorize_admin_or_principal_or_system_or_teacher!
    unless current_user.admin? || current_user.principal? || current_user.system? || current_user.teacher?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
