class HomeController < ApplicationController
  before_action :reminder_subscription, unless: -> { session[:reminder_sent] }
  ATTENDANCE_TIMESTAMP_CONDITION = "attendances.timestamp >= ?".freeze

  def index
    if current_user.school_id.nil?
      redirect_to root_path, alert: "You are not associated with any school."
      return
    end

    @school = School.find_by(id: current_user.school_id)
    school_classrooms = Classroom.where(school_id: current_user.school_id).pluck(:id)

    # Students
    @students = {
      total: Student.where(classroom_id: school_classrooms).count,
      active: Student.where(is_active: true, classroom_id: school_classrooms).count
    }
    @students[:inactive] = @students[:total] - @students[:active]

    # Teachers
    @teachers = {
      total: User.where(role: "teacher", school_id: current_user.school_id, approved: true).count
    }

    # Attendance
    base_attendance_scope = Attendance.joins(:student).where(students: { classroom_id: school_classrooms })
    @attendance = {
      last_checkin: base_attendance_scope.maximum(:timestamp),
      checkins_today: base_attendance_scope.where(ATTENDANCE_TIMESTAMP_CONDITION, Time.zone.now.beginning_of_day).count,
      unique_checkins_today: base_attendance_scope.where(ATTENDANCE_TIMESTAMP_CONDITION, Time.zone.now.beginning_of_day).select(:student_id).distinct.count,
      checkins_this_month: base_attendance_scope.where(ATTENDANCE_TIMESTAMP_CONDITION, Time.zone.now.beginning_of_month).count,
      unique_checkins_this_month: base_attendance_scope.where(ATTENDANCE_TIMESTAMP_CONDITION, Time.zone.now.beginning_of_month).select(:student_id, "DATE(attendances.timestamp)").distinct.count,
      unique_attendance_days: base_attendance_scope.select(:student_id, "DATE(attendances.timestamp)").distinct.count
    }

    today = Time.zone.today
    first_attendance_date = base_attendance_scope.minimum(:timestamp)&.to_date || today
    total_days = (today - first_attendance_date).to_i + 1
    days_this_month = (today - today.beginning_of_month).to_i + 1

    total_possible_checkins = @students[:active] * total_days
    total_possible_checkins_this_month = @students[:active] * days_this_month

    @attendance[:rates] = {
      today: @students[:active].zero? ? 0 : ((@attendance[:unique_checkins_today].to_f / @students[:active]) * 100).round(1),
      month: total_possible_checkins_this_month.zero? ? 0 : ((@attendance[:unique_checkins_this_month].to_f / total_possible_checkins_this_month) * 100).round(1),
      overall: total_possible_checkins.zero? ? 0 : ((@attendance[:unique_attendance_days].to_f / total_possible_checkins) * 100).round(1)
    }
  end
  private
  def reminder_subscription
    school = School.find_by(id: current_user.school_id)
    if school && !session[:reminder_sent]
      PaymentMailer.reminder_email(school).deliver_now
      session[:reminder_sent] = true
    end
  end
end
