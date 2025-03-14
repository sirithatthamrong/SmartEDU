class HomeController < ApplicationController
  def index
    if current_user.school_id.nil?
      redirect_to root_path, alert: "You are not associated with any school."
      return
    end

    @total_students = Student.joins(:classroom)
                             .where(classrooms: { school_id: current_user.school_id })
                             .where(is_active: true)
                             .count

    @attendance_count = Attendance.joins(:student)
                                  .where(students: { classroom_id: Classroom.where(school_id: current_user.school_id) })
                                  .count

    @last_checkin = Attendance.joins(:student)
                              .where(students: { classroom_id: Classroom.where(school_id: current_user.school_id) })
                              .maximum(:timestamp)
  end
end
