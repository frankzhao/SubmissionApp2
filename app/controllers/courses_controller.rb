class CoursesController < ApplicationController
  before_action :require_logged_in
  before_action :require_convenor_or_admin, :only => [:new, :create, :destroy, :edit]

  respond_to :html

  def index
    if current_user.is_admin?
      @courses = Course.all
    else
      @courses = current_user.courses
    end
  end

  def new
    @course = Course.new
  end

  def create
    students    = sanitize_uids(params[:students])
    tutors      = sanitize_uids(params[:tutors])
    convenors   = sanitize_uids(params[:convenors])

    if current_user.is_convenor?
      convenors << current_user.uid
    end

    # Create the course
    course = Course.create!(course_params)

    enroll_users(course, students, tutors, convenors)

    for u in course.users
      u.assignments << c.assignments
    end

    redirect_to courses_path
  end

  def edit
    @course = Course.find(params[:id])
    respond_with @course
  end

  def update
    @course = Course.find_by_id(params[:id])
    @course.update_attributes(
      :code => params[:code],
      :name => params[:name],
      :description => params[:description]
    )
    
    students = sanitize_uids(params[:students])
    tutors = sanitize_uids(params[:tutors])
    convenors = sanitize_uids(params[:convenors])

    enroll_users(@course,
      students, tutors, convenors
    )

    for u in @course.users
      u.assignments << @course.assignments
    end

    respond_with @course
  end

  def show
    if params[:id] && Course.find_by_id(params[:id])
      @course = Course.find_by_id(params[:id])
      @all_students = @course.get_student_roles
      @population = @all_students.count
      @all_assignments = @course.assignments
      @groups = @course.groups
      if !@course.users.include?(current_user) && !current_user.is_staff?
        flash_message :error, "You don't have permission to access that."
        redirect_to root_path
      end
    else
      flash_message :error, "Could not find a course with ID=" + params[:id].to_s
      redirect_to root_path
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    respond_with @course
  end
  
  def groups
    @course = Course.find(params[:id])
    @groups = @course.groups
  end
  
  private
  
  def enroll_users(c, students, tutors, convenors)
    student_list = Array.new
    counter = 0
    students.each do |s|
      # Remove spaces
      s.gsub!(/\s+/, "")
      student_list << s
      
      user = User.find_by_uid(s)
      if user
        hash = {}
        hash["#{c.id}"] = "Student"
        user.update_attributes(role: user.role.to_h.merge(hash))
        user.courses << c unless user.courses.include?(c)
      end

      if !User.find_by_uid(s).nil?
        s = User.find_by_uid(s)
        if !c.get_student_roles.include?(s)
          hash = {}
          hash["#{c.id}"] = "Student"
          s.update_attributes(role: s.role.to_h.merge(hash))
          s.courses << c unless s.courses.include?(c)
          counter += 1
        end
      else
        # Look up student details
        ldap_user = AnuLdap.find_by_uni_id(s)
        if !ldap_user.nil?
          s = User.create(:uid => s, :firstname => ldap_user[:given_name].force_encoding('ISO-8859-1'), :surname => ldap_user[:surname].force_encoding('ISO-8859-1'))
          hash = {}
          hash["#{c.id}"] = "Student"
          s.update_attributes(role: s.role.to_h.merge(hash))
          s.courses << c unless s.courses.include?(c)
          counter += 1
        else
          flash_message :error, "The student <#{s}> could not be found on the LDAP server."
        end
      end
    end
    
    for s in c.get_student_roles
      if !student_list.include?(s.uid)
        # Remove from course
        s.courses.delete(c)
        begin
          c.students.delete(s)
        rescue
        end
        s.role.delete(c.id.to_s)
        s.update_attributes(role: s.role)

        # Remove from groups
        for g in s.groups
          if g.course == c
            s.groups.delete(g)
            g.users.delete(s)
          end
        end
      end
    end
    
    flash_message :success, "Sucessfully enrolled #{counter} students." unless counter == 0
    
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
  
  def sanitize_uids(str)
    str.gsub(/\r/, '').gsub(/^$\n/, '').split(/\n/).reject(&:empty?)
  end

  def course_params
    params.require(:code)
    params.require(:name)
    params.require(:description)
    params.permit(:code, :name, :description)
  end

end
