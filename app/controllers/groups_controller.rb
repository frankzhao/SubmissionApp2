class GroupsController < ApplicationController
  before_filter :require_logged_in

  respond_to :html

  def new
    @course = Course.find(params[:id])
  end

  def create
    course = params[:course_id]
    students = sanitize_uids(params[:students])
    tutors = sanitize_uids(params[:tutors])
    
    # Clean up empty CSV rows
    out = Array.new
    for s in students
      if (s =~ /\A,+\Z/).nil?
        out << s
      end
    end
    students = out
    
    out = Array.new
    for t in tutors
      if (t =~ /\A,+\Z/).nil?
        out << t
      end
    end
    tutors = out

    for s in students
      s = s.split(',')
      if s.length == 1
        flash_message :error, "A group was not specified for the student #{s}"
        #redirect_to "/courses/#{params[:course_id]}/groups/new"
      #elsif !User.find_by_uid(s[0])
      #  flash_message :error, "User #{s} has not been enrolled in a course."
        #redirect_to "/courses/#{params[:course_id]}/groups/new"
      else
        enroll_users(course, s[0].strip, s[1].strip, "student")
      end
    end

    for t in tutors
      t = t.split(',')
      if t.length == 1
        flash_message :error, "A group was not specified for the tutor #{t}"
        #redirect_to "/courses/#{params[:course_id]}/groups/new"
      #elsif !User.find_by_uid(t[0])
      #  flash_message :error, "User #{s} has not been enrolled in the course."
        #redirect_to "/courses/#{params[:course_id]}/groups/new"
      else
        enroll_users(course, t[0].strip, t[1].strip, "tutor")
      end
    end

    redirect_to course_path(course)
  end

  def show
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to '/'
    end
    @group = Group.find(params[:id])
  end

  def index
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to '/'
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to course_path(@group.course)
  end

  private

  def enroll_users(c, uid, g, type)
    counter = 0
    uid.gsub!(/\s+/, "") # remove spaces

    # Check if the group exists
    group = Group.find_by_name(g)
    c = Course.find(c)
    if !group
      new_group = Group.create(:name => g, :course => c)
      c.groups << new_group
      group = new_group
    end

    if group
      if (group.course == c) && type == "student"
        s = Student.find_by_uid(uid)
        if s && c.students.include?(s)
          if !group.students.include?(s)
            group.students << Student.find_by_uid(uid)

            # Remove existing groups
            for g in Student.find_by_uid(uid).groups
              if g.course == c
                Student.find_by_uid(uid).groups.delete(g)
              end
            end

            # Add group to student's groups
            Student.find_by_uid(uid).groups << group
            counter += 1
            Notification.create_and_distribute("You have been enrolled as #{type} for #{c.code}: #{group.name}", group_path(group), [s])
          end
        else
          flash_message :error, "The #{type} <#{uid}> is not enrolled in #{c.code}."
        end
      elsif type == "tutor"
        t = Tutor.find_by_uid(uid)
        if t && !(group.tutor == t)
          group.tutor = t
          group.save!
          t.groups << group
          counter += 1
        elsif t.nil?
          # Look up tutor details
          ldap_user = AnuLdap.find_by_uni_id(uid)
          if ldap_user
            t = Tutor.create(:uid => t, :firstname => ldap_user[:given_name], :surname => ldap_user[:surname])
            c.tutors << t
            group.tutor = t
            group.save!
            t.courses << c
            # add to group
            group.tutor = t
            counter += 1
            Notification.create_and_distribute("You have been enrolled as #{type} for #{c.code}: #{group.name}", group_path(group), [t])
          else
            flash_message :error, "The tutor <#{t}> could not be found on the LDAP server."
          end
        end
      end
    end
  end
  
  def sanitize_uids(str)
    str.gsub(/\r/, '').gsub(/^$\n/, '').split(/\n/).reject(&:empty?)
  end
  
end
