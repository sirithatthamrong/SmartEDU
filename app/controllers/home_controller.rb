class HomeController < ApplicationController
  def index
    if current_user.school_id.nil?
      redirect_to root_path, alert: "You are not associated with any school."
      return
    end

    school_classrooms = Classroom.where(school_id: current_user.school_id).pluck(:id)

    @total_students = Student.where(classroom_id: school_classrooms).count

    @active_students = Student.where(is_active: true, classroom_id: school_classrooms).count
    @inactive_students = @total_students - @active_students

    @attendance_count = Attendance.joins(:student)
                                  .where(students: { classroom_id: school_classrooms })
                                  .count

    @attendance_rate = @active_students.zero? ? 0 : ((@attendance_count.to_f / @active_students) * 100).round(1)

    @last_checkin = Attendance.joins(:student)
                              .where(students: { classroom_id: school_classrooms })
                              .maximum(:timestamp)

    @recent_checkins = Attendance.joins(:student)
                                 .where(students: { classroom_id: school_classrooms })
                                 .order(timestamp: :desc)
                                 .limit(5)
  end
end
