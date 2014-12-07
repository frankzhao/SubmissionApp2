class GroupsController < ApplicationController
  before_filter :require_logged_in

  respond_to :html

  def new
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
      enroll_users(course, s[0].lstrip.rstrip, s[1].lstrip.rstrip, "student")
    end

    for t in tutors
      t = t.split(',')
      enroll_users(course, t[0].lstrip.rstrip, t[1].lstrip.rstrip, "tutor")
    end

    redirect_to course_path(course)
  end

  def edit
  end

  def show
    @group = Group.find(params[:id])
  end

  def index
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
            Student.find_by_uid(uid).groups << group
            counter += 1
            Notification.create_and_distribute("You have been enrolled as #{type} for #{c.code}: #{group.name}", group_path(group), [s])
          end
        else
          flash_message :error, "The #{type} <#{uid}> is not enrolled in #{c.code}."
        end
      elsif type == "tutor"
        t = Tutor.find_by_uid(uid)
        if t && !group.tutors.include?(t)
          group.tutor = t
          t.groups << group
          counter += 1
        elsif t.nil?
          # Look up tutor details
          ldap_user = AnuLdap.find_by_uni_id(t)
          if ldap_user
            t = Tutor.create(:uid => t, :firstname => ldap_user.given_name, :surname => ldap_user.surname)
            c.tutors << t
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
