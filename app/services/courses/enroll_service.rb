module Courses
  class EnrollService < BaseService
    attr_accessor :success_count, :errors

    def initialize(course, opts)
      super(course, opts)
      @convenors = @opts[:convenors]&.split("\n") || []
      @students = @opts[:students]&.split("\n") || []
      @tutors = @opts[:tutors]&.split("\n") || []
      @success_count = {
          students: 0,
          convenors: 0,
          tutors: 0
      }
      @errors = {
          students: [],
          convenors: [],
          tutors: []
      }
    end

    def execute
      enroll_students
      enroll_tutors
      enroll_convenors
    end

    def add_convenor(user)
      @convenors << user.uid
    end

    private

    def extract_uids(uids)
      ::Ldap::SanitizeService.new(uids).execute.split(/\n/).reject(&:empty?)
    end

    def clean_input(input)
      input.sub(/\s+/, '')
    end

    def enroll_students
      student_list = [] # list of students added in this session

      @students.each do |s|
        # Remove spaces
        s = clean_input(s)
        student_list << s

        user = User.find_or_create_by_uid(s)

        if user
          user.add_to_course_as_student(@course)
          @success_count[:students] += 1
        else
          @errors[:student] << s
        end
      end

      # un-enrolls students who are no longer in the course
      @course.get_student_roles.each do |s|
        unless student_list.include?(s.uid)
          s.remove_from_course(@course)
          # Remove from groups
          s.groups.each do |g|
            if g.course == @course
              # s.groups.delete(g) # will actually delete the group
              g.users.delete(s)
            end
          end
        end
      end
    end

    def enroll_tutors
      old_tutors = @course.get_tutor_roles
      old_tutors.each do |tutor|
        tutor.remove_from_course(@course)
      end

      @tutors.each do |t|
        # Remove spaces
        t = clean_input(t)

        user = User.find_or_create_by_uid(t)
        if user
          user.add_to_course_as_tutor(@course)
          @success_count[:tutors] += 1
        else
          @errors[:tutors] << t
        end
      end
    end

    def enroll_convenors
      old_convenors = @course.get_convenor_roles
      old_convenors.each do |convenor|
        convenor.remove_from_course(@course)
      end

      @convenors.each do |c|
        # Remove spaces
        c = clean_input(c)

        user = User.find_or_create_by_uid(c)
        if user
          user.add_to_course_as_convenor(@course)
          @success_count[:convenors] += 1
        else
          @errors[:convenors] << t
        end
      end
    end
  end
end
