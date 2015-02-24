class AssignmentsController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convenor_or_admin, :except => [:show, :index, :groups, :data]

  require 'zip'
  
  def new
    @assignment = Assignment.new
    if params[:course_id] && Course.find_by_id(params[:course_id])
      @course = Course.find_by_id(params[:course_id])
    else
      flash_message :error, "The course with ID=" + params[:course_id].to_s + " was not found."
      redirect_to courses_url
    end
  end

  def create
    course = params[:course_id]
    name = params[:assignment_name]
    date_due = params[:date_due]
    type = params[:type]
    text = params[:text]
    tests = params[:tests]
    peer_review = params[:assignment][:peer_review_enabled]

    if course && Course.find_by_id(course)
      c = Course.find_by_id(course)

      # Parse due date
      date_due = Chronic.parse(date_due)
      assignment = Assignment.create(:name => name, :due_date => date_due,
                                   :description => text, :kind => type, :tests => tests,
                                   peer_review_enabled: peer_review)
      # Add assignment to the course
      Course.find(course).assignments << assignment
      
      # Distribute and notify assignment to users in the course
      notification = Notification.create_and_distribute("New assignment: " + assignment.name, assignment_path(assignment), c.users)
      for u in c.users
        u.assignments << assignment
      end
    else
      flash_message :error, "Could not find course with ID=" + course.to_s
    end

    redirect_to course_path(course)
  end

  def edit
    @assignment = Assignment.find(params[:id])
    @course = @assignment.course
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    date_due = Chronic.parse(params[:date_due])
    @assignment.update_attributes(
      :name => params[:assignment_name],
      :due_date => date_due,
      :kind => params[:assignment][:kind],
      :description => params[:text],
      :tests => params[:tests],
      :peer_review_enabled => params[:assignment][:peer_review_enabled]
    )
    
    redirect_to assignment_path(@assignment)
  end

  def show
    if params[:id] && Assignment.find_by_id(params[:id])
      @assignment = Assignment.find_by_id(params[:id])
      @course = @assignment.course
      @submissions = current_user.submissions_for(@assignment)
    else
      flash_message :error, "Could not find assignment with ID=" + params[:id]
      redirect_to '/'
    end
  end

  def index
    if current_user.is_admin?
      @assignments = Assignment.all
    else
      @assignments = current_user.assignments
    end
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy
    
    redirect_to '/courses'
  end
  
  def data
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to '/'
    end
    assignment = Assignment.find(params[:id])
    data = assignment.submissions.group("strftime('%Y%m%d %H', created_at)").count
    render :json => {data: data}
  end
  
  # Assignment group views
  def groups
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to '/'
    end
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:group_id])
    @submissions = @assignment.submissions.select{
      |s| s.user.type == "Student" && @group.students.include?(s.user)
    }
    @comment = Comment.new
    
    render 'group_assignment'
  end
  
  def download_all_submissions
    @assignment = Assignment.find(params[:assignment_id])
    
    if @assignment.submissions.blank?
      flash_message :error, "Assignment has no submissions for download."
      redirect_to :back
      return
    end
    
    files = []
    for submission in @assignment.submissions
      if @assignment.kind == 'zip'
        files << submission.zipfile_path
      elsif @assignment.kind == 'plaintext'
        files << submission.plaintext_path
      end
    end
    
    # Zip files
    `mkdir -p #{Rails.root}/tmp/downloads/`
    currtime = sanitize_str Time.now
    zipfile_name = "#{Rails.root}/tmp/downloads/#{sanitize_str @assignment.name}_#{currtime}.zip"

    unless File.exists?(zipfile_name)
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        for file in files
          filename = file.split('/').last
          zipfile.add(filename, file)
        end
      end
    end

    send_file zipfile_name, :type=>"application/zip", :x_sendfile=>true
  end
  
  def download_all_submissions_for_group
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:group_id])
    group_submissions =
      @assignment.submissions.select{|s| s.user.type == "Student" && s.user.groups.include?(@group)}
    if group_submissions.blank?
      flash_message :error, "Group has no submissions for download."
      redirect_to :back
      return
    end
    
    files = []
    for submission in group_submissions
      if @assignment.kind == 'zip'
        files << submission.zipfile_path
      elsif @assignment.kind == 'plaintext'
        files << submission.plaintext_path
      end
    end
    
    # Zip files
    `mkdir -p #{Rails.root}/tmp/downloads/`
    zipfile_name = "#{Rails.root}/tmp/downloads/#{sanitize_str @assignment.name}_#{sanitize_str @group.name}__#{sanitize_str Time.now}.zip"

    unless File.exists?(zipfile_name)
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        for file in files
          filename = file.split('/').last
          zipfile.add(filename, file)
        end
      end
    end
    
    send_file zipfile_name, :type=>"application/zip", :x_sendfile=>true
  end
  
end
