module Courses
  class AssignmentService < BaseService
    def execute
      @course.users.each do |user|
        user.assignments << @course.assignments
      end
    end
  end
end