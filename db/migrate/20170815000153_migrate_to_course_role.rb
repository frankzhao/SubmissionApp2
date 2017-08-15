class CoursesUsers < ApplicationRecord
  self.table_name = 'courses_users'
end

class MigrateToCourseRole < ActiveRecord::Migration[5.0]
  def up


    # migrate the role field in users
    ActiveRecord::Base.transaction do
      # delete the stupid test user
      user = User.find_by_uid("u0000002")

      if user.present?
        CoursesUsers.where(user_id: user.id).delete_all
        CoursesUsers.where(student_id: user.id).delete_all
        user.destroy
      end


      User.find_each do |u|
        next if u.role.nil?

        roles = u.role.to_h

        roles.each do |course_id, role_name|
          course = Course.find_by_id(course_id.to_i)
          next if course.nil?
          CourseRole.create!(user: u, course: course, role: role_name.downcase)
        end
      end

      # migrate the STI relationship in 'courses_users'
      CoursesUsers.find_each do |cu|
        next if cu.user_id.nil?
        course = Course.find_by_id(cu.course_id)
        user = User.find(cu.user_id)

        next if course.nil?

        next if user.role.to_h[course.id.to_s].present?

        is_tutor = Group.where(tutor_id: user.id, course: course).exists? || Group.where(user_id: user.id, course: course).exists?

        if is_tutor
          CourseRole.create!(user: user, course: course, role: 'tutor')
        else
          CourseRole.create!(user: user, course: course, role: 'student')
        end
      end

      CoursesUsers.find_each do |cu|
        next if cu.student_id.nil?
        course = Course.find_by_id(cu.course_id)
        user = User.find(cu.student_id)
        next if course.nil?

        next if user.role.to_h[course.id.to_s].present?

        # check for repeat
        repeat = CourseRole.find_by(user: user, course: course)
        next if repeat && repeat.role == 'student'

        CourseRole.create!(user: user, course: course, role: 'student')
      end

      CoursesUsers.find_each do |cu|
        next if cu.convenor_id.nil?
        course = Course.find_by_id(cu.course_id)
        user = User.find(cu.convenor_id)

        next if course.nil?
        next if user.role.to_h[course.id.to_s].present?

        CourseRole.create!(user: user, course: course, role: 'convenor')
      end
    end
  end

  def down
    CourseRole.delete_all
  end
end
