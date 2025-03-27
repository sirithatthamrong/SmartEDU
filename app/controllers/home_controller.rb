class HomeController < ApplicationController
  def index
    if current_user.school_id.nil?
      redirect_to root_path, alert: "You are not associated with any school."
      return
    end

    school_classrooms = Classroom.where(school_id: current_user.school_id).pluck(:id)

    # Total Students
    @total_students = Student.where(classroom_id: school_classrooms).count
    @active_students = Student.where(is_active: true, classroom_id: school_classrooms).count
    @inactive_students = @total_students - @active_students

    # Total Teachers
    @total_teachers = User.where(role: "teacher", school_id: current_user.school_id, approved: true).count

    # Attendance
    base_attendance_scope = Attendance.joins(:student).where(students: { classroom_id: school_classrooms })

    @last_checkin = base_attendance_scope.maximum(:timestamp)

    # Today's Check-ins
    @checkins_today = base_attendance_scope.where("attendances.timestamp >= ?", Time.zone.now.beginning_of_day).count
    @unique_checkins_today = base_attendance_scope
                               .where("attendances.timestamp >= ?", Time.zone.now.beginning_of_day)
                               .select(:student_id)
                               .distinct
                               .count

    # Monthly Check-ins
    @checkins_this_month = base_attendance_scope.where("attendances.timestamp >= ?", Time.zone.now.beginning_of_month).count
    @unique_checkins_this_month = base_attendance_scope
                                    .where("attendances.timestamp >= ?", Time.zone.now.beginning_of_month)
                                    .select(:student_id, "DATE(attendances.timestamp)")
                                    .distinct
                                    .count

    # Overall Attendance (unique student+day combinations)
    @unique_attendance_days = base_attendance_scope
                                .select(:student_id, "DATE(attendances.timestamp)")
                                .distinct
                                .count

    # Calculate possible check-ins
    today = Time.zone.today

    first_attendance_date = base_attendance_scope.minimum(:timestamp)&.to_date || today
    total_days = (today - first_attendance_date).to_i + 1
    days_this_month = (today - today.beginning_of_month).to_i + 1

    total_possible_checkins = @active_students * total_days
    total_possible_checkins_this_month = @active_students * days_this_month

    # Attendance Rates
    @attendance_rate_today = @active_students.zero? ? 0 :
                               ((@unique_checkins_today.to_f / @active_students) * 100).round(1)

    @attendance_rate_month = total_possible_checkins_this_month.zero? ? 0 :
                               ((@unique_checkins_this_month.to_f / total_possible_checkins_this_month) * 100).round(1)

    @attendance_rate = total_possible_checkins.zero? ? 0 :
                         ((@unique_attendance_days.to_f / total_possible_checkins) * 100).round(1)
  end
end
