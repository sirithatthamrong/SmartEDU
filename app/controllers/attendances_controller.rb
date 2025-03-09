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
    Rails.logger.info("Creating Checkin")
    Rails.logger.info(params)

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

  def checkin
    uid = params[:uid]
    hash = params[:hash]

    secret = Rails.application.credentials.secret_key_base
    expected = Digest::SHA256.hexdigest("#{uid}|#{secret}")

    if hash != expected
      render json: { success: false, message: "Invalid QR code" }
      return
    end

    student = Student.find_by(uid: uid)
    if student
      CheckinService.checkin(student, current_user)
      message = "Student checked in successfully at #{Time.current.strftime('%H:%M:%S')}."
      respond_to do |format|
        format.json { render json: { success: true, message: message } }
        format.html { redirect_to admin_scan_qr_path, notice: message }
      end
    else
      message = "Student not found."
      respond_to do |format|
        format.json { render json: { success: false, message: message } }
        format.html { redirect_to admin_scan_qr_path, alert: message }
      end
    end
  end

  def check_if_checked_in
    Rails.logger.info("Checking if student is checked in")
    Rails.logger.info(params)
    student = Student.find(params[:attendance_id])

    # Check if the student has already checked in today
    existing_attendance = Attendance.where(student: student)
                                    .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                                    .first
    if existing_attendance
      render json: { checked_in: true }
    else
      render json: { checked_in: false }
    end
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
