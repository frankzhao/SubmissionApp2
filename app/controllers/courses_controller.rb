class CoursesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convenor_or_admin, :only => [:new, :create, :destroy, :edit]

  respond_to :html

  def new
    @course = Course.new
  end

  def create
    course_code = params[:course_code]
    course_name = params[:name]
    description = params[:description]
    students    = sanitize_uids(params[:students])
    tutors      = sanitize_uids(params[:tutors])
    convenors   = sanitize_uids(params[:convenors])

  if current_user.is_convenor?
    convenors << current_user.uid
  end


    # Create the course
    c = Course.create(
      :code => course_code,
      :name => course_name,
      :description => description)

    enroll_users(c, students, tutors, convenors)

    for u in c.users
      u.assignments << c.assignments
    end

    redirect_to '/courses'
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
      @groups = @course.groups
      if !@course.users.include?(current_user) && !current_user.is_staff?
        flash_message :error, "You don't have permission to access that."
        redirect_to '/'
      end
    else
      flash_message :error, "Could not find a course with ID=" + params[:id].to_s
      redirect_to "/"
    end
  end

  def index
    if current_user
      if current_user.is_admin?
        @courses = Course.all
      else
        @courses = current_user.courses
      end
    else
      redirect_to "/"
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    respond_with @course
  end
  
  def groups
    @course = Course.find(params[:id])
    respond_with @course
  end
  
  private
  
  def enroll_users(c, students, tutors, convenors)
    if not students.empty?
      counter = 0
      students.each do |s|
        # Remove spaces
        s.gsub!(/\s+/, "")

        if !Student.find_by_uid(s).nil?
          s = Student.find_by_uid(s)
          if !c.students.include?(s)
            c.students << s
            s.courses << c
            counter += 1
          end
        else
          # Look up student details
          ldap_user = AnuLdap.find_by_uni_id(s)
          if !ldap_user.nil?
            s = Student.create(:uid => s, :firstname => ldap_user[:given_name].force_encoding('ISO-8859-1'), :surname => ldap_user[:surname].force_encoding('ISO-8859-1'))
            c.students << s
            s.courses << c
            counter += 1
          else
            flash_message :error, "The student <#{s}> could not be found on the LDAP server."
          end
        end
      end
      flash_message :success, "Sucessfully enrolled #{counter} students." unless counter == 0
    end

    if not tutors.empty?
      counter = 0
      tutors.each do |t|
        # Remove spaces
        t.gsub!(/\s+/, "")

        if !Tutor.find_by_uid(t).nil?
          t = Tutor.find_by_uid(t)
          if !c.tutors.include?(t)
            c.tutors << t
            t.courses << c
            counter += 1
          end
        else
          # Look up user details
          ldap_user = AnuLdap.find_by_uni_id(t)
          if !ldap_user.nil?
            t = Tutor.create(:uid => t, :firstname => ldap_user[:given_name], :surname => ldap_user[:surname])
            c.tutors << t
            t.courses << c
            counter += 1
          else
            flash_message :error, "The tutor <#{t}> could not be found on the LDAP server."
          end
        end
      end
      flash_message :success, "Sucessfully enrolled #{counter} tutors." unless counter == 0
    end

    if not convenors.empty?
      counter = 0
      convenors.each do |conv|
        # Remove spaces
        conv.gsub!(/\s+/, "")

        if !Convenor.find_by_uid(conv).nil?
          conv = Convenor.find_by_uid(conv)
          if !c.convenors.include?(conv)
            c.convenors << conv
            conv.courses << c
            counter += 1
          end
        else
          # Look up user details
          ldap_user = AnuLdap.find_by_uni_id(conv)
          if !ldap_user.nil?
            conv = Convenor.create(:uid => conv, :firstname => ldap_user[:given_name], :surname => ldap_user[:surname])
            c.convenors << conv
            #conv.courses << c
            counter += 1
          else
            flash_message :error, "The convenor <#{conv}> could not be found on the LDAP server."
          end
        end
      end
      flash_message :success, "Sucessfully enrolled #{counter} convenors." unless counter == 0
    end
  end
  
  def sanitize_uids(str)
    str.gsub(/\r/, '').gsub(/^$\n/, '').split(/\n/).reject(&:empty?)
  end

end
