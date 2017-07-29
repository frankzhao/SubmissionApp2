module Courses
  class EnrollService < BaseService
    def initialize(course, opts)
      super(course, opts)
      @convenors = @opts[:convenors] || []
      @students = @opts[:students] || []
      @tutors = @opts[:tutors] || []
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
    end

    def add_convenor(user)
      @convenors << user.uid
    end

    private

    def extract_uids(uids)
      ::Ldap::SanitizeService.new(uids).execute.split(/\n/).reject(&:empty?)
    end

    def enroll_students
      student_list = []

      @students.each do |s|
        # Remove spaces
        s.gsub!(/\s+/, "")
        student_list << s

        user = User.find_or_create_by_uid(uid)

        if user
          user.add_to_course_as_student(@course)
          @success_count[:students] += 1
        else
          @errors[:student] << s
        end
      end

      # un-enrolls students who are no longer in the course
      for s in @course.get_student_roles
        unless student_list.include?(s.uid)
          # Remove from course
          s.courses.delete(@course)
          begin
            @course.students.delete(s)
          rescue ActiveRecord::RecordNotFound
            # ignored
          end
          s.role.delete(@course.id.to_s)
          s.update_attributes(role: s.role)

          # Remove from groups
          for g in s.groups
            if g.course == @course
              s.groups.delete(g)
              g.users.delete(s)
            end
          end
        end
      end
    end
  end
end


def enroll_users(tutors, convenors)
  c = @course

  c.tutors = []
  old_tutors = User.select{|u| u.role["#{c.id}"] == "Tutor" unless u.role.nil?}.uniq
  for tutor in old_tutors
    tutor.update_attributes(role: tutor.role.delete(c.id))
  end
  if not tutors.empty?
    counter = 0
    tutors.each do |t|
      # Remove spaces
      t.gsub!(/\s+/, "")

      user = User.find_by_uid(t)
      if user
        hash = {}
        hash["#{c.id}"] = "Tutor"
        user.update_attributes(role: user.role.to_h.merge(hash))
        user.courses << c unless user.courses.include?(c)
      end

      if !User.find_by_uid(t).nil?
        t = User.find_by_uid(t)
        if !c.get_tutor_roles.include?(t)
          c.tutors << t
          t.courses << c unless t.courses.include?(c)
          counter += 1
        end
      else
        # Look up user details
        ldap_user = AnuLdap.find_by_uni_id(t)
        if !ldap_user.nil?
          t = User.create(:uid => t, :firstname => ldap_user[:given_name].force_encoding('ISO-8859-1'), :surname => ldap_user[:surname].force_encoding('ISO-8859-1'))
          hash = {}
          hash["#{c.id}"] = "Tutor"
          t.update_attributes(role: t.role.to_h.merge(hash))
          t.courses << c unless t.courses.include?(c)
          counter += 1
        else
          flash_message :error, "The tutor <#{t}> could not be found on the LDAP server."
        end
      end
    end
    flash_message :success, "Sucessfully enrolled #{counter} tutors." unless counter == 0
  end

  old_convenors = User.select{|u| u.role["#{c.id}"] == "Convenor" unless u.role.nil?}.uniq
  for convenor in old_convenors
    convenor.update_attributes(role: convenor.role.delete(c.id))
  end
  c.convenors = []
  if not convenors.empty?
    counter = 0
    convenors.each do |conv_id|
      # Remove spaces
      conv_id.gsub!(/\s+/, "")

      user = User.find_by_uid(conv_id)
      if user
        hash = {}
        hash["#{c.id}"] = "Convenor"
        user.update_attributes(role: user.role.to_h.merge(hash))
        user.courses << c unless user.courses.include?(c)
      else
        conv = Convenor.find_by_uid(conv_id)
        if conv
          if !c.convenors.include?(conv)
            c.convenors << conv
            counter += 1
          end
        else
          # Look up user details
          ldap_user = AnuLdap.find_by_uni_id(conv_id)
          if ldap_user
            conv = Convenor.create(:uid => conv_id, :firstname => ldap_user[:given_name].force_encoding('ISO-8859-1'), :surname => ldap_user[:surname].force_encoding('ISO-8859-1'))
            c.convenors << conv unless c.convenors.include?(conv)
            counter += 1
          else
            flash_message :error, "The convenor <#{conv_id}> could not be found on the LDAP server."
          end
        end
      end
    end
    flash_message :success, "Sucessfully enrolled #{counter} convenors." unless counter == 0
  end
end
