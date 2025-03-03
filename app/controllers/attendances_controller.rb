class AttendancesController < ApplicationController
  before_action :set_attendance, only: %i[ show edit update destroy ]
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
      render json: { status: "already_checked_in" }, status: :ok
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

  # app/controllers/attendances_controller.rb
  def destroy
    # Fetch the student based on the student_id passed in params
    student = Student.find(params[:student_id])

    # Assuming you want to undo today's check-in for this student:
    CheckinService.undo_checkin(student)

    respond_to do |format|
      format.html { redirect_to student_attendances_path(student), notice: "Undo Check in successfully!" }
      format.turbo_stream
    end
  end

  def check_if_checked_in
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
    # # Use callbacks to share common setup or constraints between actions.
    # def set_attendance
    #   @attendance = Attendance.find(params.expect(:id))
    # end

    # Only allow a list of trusted parameters through.
    def attendance_params
      params.expect(attendance: [ :student_id, :timestamp, :user_id ])
    end
end
