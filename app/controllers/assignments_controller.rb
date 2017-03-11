class AssignmentsController < ApplicationController
  before_action :require_logged_in
  before_action :require_convenor_or_admin, :except => [:show, :index, :groups, :data, :download_all_submissions_for_group, :group_data, :download_group_archives, :download_group_archives, :download_all_finals]
  before_action :require_staff, :only => [:download_all_submissions_for_group, :download_group_archives, :download_all_finals]

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
    text = params[:text]
    tests = params[:tests]
    peer_review = params[:assignment][:peer_review_enabled]
    copy_path = params[:assignment][:copy_path]

    if course && Course.find(course)
      c = Course.find(course)

      # Parse due date
      date_due = Chronic.parse(date_due, :endian_precedence => [:little, :median])
      assignment = Assignment.create(
        :name => name,
        :due_date => date_due,
        :description => text,
        :kind => params[:assignment][:kind],
        :tests => tests,
        :peer_review_enabled => peer_review,
        :copy_path => copy_path,
        :disable_compilation => params[:assignment][:disable_compilation],
        :lang => params[:assignment][:lang],
        :custom_compilation => params[:assignment][:custom_compilation],
        :custom_command => params[:assignment][:custom_command],
        :pdf_regex => params[:assignment][:pdf_regex],
        :zip_regex => params[:assignment][:zip_regex],
        :timeout => params[:assignment][:timeout]
      )
      # Add assignment to the course
      c.assignments << assignment
      
      # Distribute and notify assignment to users in the course
      if assignment
        notification = Notification.create_and_distribute("New assignment: " + assignment.name, assignment_path(assignment), c.users)
        for u in c.users
          u.assignments << assignment
        end
      else
        flash_message :error, "Could not create the course. Please check the input fields."
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
    old_folder = sanitize_str(@assignment.name)
    new_folder = sanitize_str(params[:assignment_name])

    if old_folder != new_folder
      # Rename upload directories if assignment is renamed
      old_path = Rails.root.to_s + "/public/uploads/#{old_folder}"
      new_path = Rails.root.to_s + "/public/uploads/#{new_folder}"
      `mv #{old_path} #{new_path}`

      # Rename uploaded submissions
      for submission in @assignment.submissions
        old_submission_path = submission.file_path.sub(/#{old_folder}/,"#{new_folder}")
        new_submission_path = submission.file_path.gsub(/#{old_folder}/,"#{new_folder}")
        if @assignment.kind == "zip"
          old_submission_path = old_submission_path + ".zip"
          new_submission_path = new_submission_path + ".zip"
        elsif @assignment.kind == "plaintext"
          old_submission_path = old_submission_path + ".txt"
          new_submission_path = new_submission_path + ".txt"
        end

        File.rename(old_submission_path, new_submission_path)
      end
    end

    date_due = Chronic.parse(params[:date_due], :endian_precedence => [:little, :median])
    @assignment.update_attributes(
      :name => params[:assignment_name],
      :due_date => date_due,
      :description => params[:text],
      :tests => params[:tests],
      :peer_review_enabled => params[:assignment][:peer_review_enabled],
      :copy_path => params[:assignment][:copy_path],
      :disable_compilation => params[:assignment][:disable_compilation],
      :lang => params[:assignment][:lang],
      :custom_compilation => params[:assignment][:custom_compilation],
      :custom_command => params[:assignment][:custom_command],
      :pdf_regex => params[:assignment][:pdf_regex],
      :zip_regex => params[:assignment][:zip_regex],
      :timeout => params[:assignment][:timeout]
    )
    
    redirect_to assignment_path(@assignment)
  end

  def show
    if params[:id] && Assignment.find_by_id(params[:id])
      @assignment = Assignment.find_by_id(params[:id])
      @course = @assignment.course
      @submissions = current_user.submissions_for(@assignment)
      if current_user.is_staff_for_course?(@course)
        @all_submissions = Submission.where(assignment_id: @assignment.id)
        @submission_hash = @all_submissions.group_by(&:id).to_h
        @finalised_submissions = @all_submissions.select{|s| s.finalised?}.group_by(&:user_id)
        @submissions_by_id = @all_submissions.group_by(&:user_id)
        @comments = @all_submissions.map(&:comments).flatten.group_by(&:submission_id)
      end
    else
      flash_message :error, "Could not find assignment with ID=" + params[:id]
      redirect_to root_path
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
    
    redirect_to root_path
  end
  
  def data
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to root_path
    end
    assignment = Assignment.find(params[:id])
    course = assignment.course
    submissions = assignment.submissions
    hourly_data = submissions.select('created_at').group("date_trunc('hour', created_at)").count.to_a.last(24*7)
    hourly_data = Hash[*hourly_data.flatten]
    daily_data = submissions.select('created_at').group("date_trunc('day', created_at)").count
    
    unique_submission_users = submissions.select{|s| (s.user.role.to_h[course.id.to_s] == "Student")}.map(&:user).uniq
    finalised = submissions.where(finalised: true)
    finalised_count = finalised.map(&:user).uniq.count
    submission_count = assignment.submissions.select{|s| (s.user.role.to_h[course.id.to_s] == "Student")}.map(&:user).uniq.count
    notfinalised = submission_count - finalised_count
    nonsubmissions = (assignment.course.get_student_roles.count - unique_submission_users.count)
    commented_submissions = assignment.submissions.select{|s| (s.user.role.to_h[course.id.to_s] == "Student" && s.comments.present?)}.map(&:user).uniq.count
    uncommented_submissions = (submission_count - commented_submissions)
    
    render :json => {
      hourly_data: hourly_data,
      daily_data: daily_data,
      finalised: finalised_count,
      notfinalised: notfinalised,
      nonsubmissions: nonsubmissions,
      commented_submissions: commented_submissions,
      uncommented_submissions: uncommented_submissions
    }
  end
  
  def group_data
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to root_path
    end
    
    data = Hash.new
    assignment = Assignment.find(params[:id])
    submissions = assignment.submissions
    finalised = submissions.select{|s| s.finalised?}
    course = assignment.course
    groups = course.groups
    
    groups_hash = Hash.new
    for group in groups
      groups_hash[group.id] = group.users
    end
    
    for group in groups
      group_data = Hash.new
      enrolled = group.users.length
      finalised_count = finalised.select{|s| groups_hash[group.id].include?(s.user)}.map(&:user).uniq.count
      submission_count = submissions.select{|s| (s.user.role.to_h[course.id.to_s] == "Student") && groups_hash[group.id].include?(s.user)}.map(&:user).uniq.length
      
      group_data["name"] = group.name.to_s
      group_data["enrolled"] = enrolled.to_i
      group_data["finalised"] = finalised_count
      group_data["submissions"] = submission_count
      group_data["tutor"] = group.user.present? ? URI::escape(group.user.full_name.to_s) : "None"
      group_data["group_url"] = group_path(group)
      group_data["group_submissions_url"] = "/assignments/#{assignment.id}/group/#{group.id}"
      
      data[group.name] = group_data
    end
    
    render :json => {data: data}
  end
  
  # Assignment group views
  def groups
    if !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to root_path
    end
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:group_id])
    @submissions = @assignment.submissions.select{
      |s| @group.users.include?(s.user)
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
          if File.exists?(file)
            filename = file.split('/').last
            zipfile.add(filename, file)
          end
        end
      end
    end

    send_file zipfile_name, :type=>"application/zip", :x_sendfile=>true
  end
  
  def download_all_submissions_for_group
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:group_id])
    group_submissions = Array.new
    for s in @group.users
      student_submissions = s.submissions_for(@assignment)
      group_submissions << student_submissions.last unless student_submissions.empty?
    end
    #group_submissions =
    #  @assignment.submissions.select{|s| s.user.type == "Student" && s.user.groups.include?(@group)}
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
          if File.exists?(file)
            filename = file.split('/').last
            zipfile.add(filename, file)
          end
        end
      end
    end
    
    send_file zipfile_name, :type=>"application/zip", :x_sendfile=>true
  end
  
  def download_all_finals
    @assignment = Assignment.find(params[:assignment_id])
    @course = @assignment.course
    final_submissions = []
    for s in @course.get_student_roles
      student_submissions = s.submissions_for(@assignment)
      final_submissions << student_submissions.last unless student_submissions.empty?
    end
    
    if final_submissions.blank?
      flash_message :error, "Assignment has no submissions for download."
      redirect_to :back
      return
    end
    
    files = []
    for submission in final_submissions
      if @assignment.kind == 'zip'
        files << submission.zipfile_path
      elsif @assignment.kind == 'plaintext'
        files << submission.plaintext_path
      end
    end
    
    # Zip files
    `mkdir -p #{Rails.root}/tmp/downloads/`
    zipfile_name = "#{Rails.root}/tmp/downloads/#{sanitize_str @assignment.name}_#{sanitize_str Time.now}.zip"

    unless File.exists?(zipfile_name)
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        for file in files
          if File.exists?(file)
            filename = file.split('/').last
            zipfile.add(filename, file)
          end
        end
      end
    end
    
    send_file zipfile_name, :type=>"application/zip", :x_sendfile=>true
  end
  
  def download_group_archives
    @group = Group.find(params[:group_id])
    @assignment = Assignment.find(params[:assignment_id])
    
    group_submissions = []
    for s in @group.users
      student_submissions = s.submissions_for(@assignment)
      group_submissions << student_submissions.last unless student_submissions.empty?
    end
    
    if group_submissions.blank?
      flash_message :error, "Group has no submissions for download."
      redirect_to :back
      return
    end
    
    files = []
    for submission in group_submissions
      submission_files = Hash.new
      user = submission.user
      attached_files = user.submissions_for(@assignment).select{
        |s| s.comments.present?}.map(&:comments).flatten.map(&:attachment).map(&:file)
      submission_files[:file] = submission.plaintext_path
      submission_files[:user] = submission.user
      
      if attached_files.compact.present?
        submission_files[:attachment] = attached_files.compact.last.path
      end
      
      files << submission_files
    end
    
    # Zip each user submission
    group_zip_folder = "#{Rails.root}/tmp/downloads/#{sanitize_str @assignment.name}"
    zipfile_name = "#{Rails.root}/tmp/downloads/#{sanitize_str @assignment.name}_#{sanitize_str @group.name}__#{sanitize_str Time.now}.zip"
    
    `rm -rf #{group_zip_folder}`
    `mkdir -p #{group_zip_folder}`
    
    for file in files
      userzipfilename = sanitize_str("#{file[:user].uid}_#{file[:user].full_name}_#{@assignment.name}.zip")
      Zip::File.open(group_zip_folder+"/"+userzipfilename, Zip::File::CREATE) do |zipfile|
        if File.exists?(file[:file])
          filename = file[:file].split('/').last
          zipfile.add(filename.gsub(".txt",".hs"), file[:file])
        end
        if file[:attachment].present?
          filename = file[:attachment].split('/').last
          zipfile.add(filename, file[:attachment])
        end
      end
    end
    
    # Create final archive
    @user_zips = Dir.glob("#{group_zip_folder}/*")
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      for file in @user_zips
        filename = file.split('/').last
        zipfile.add(filename, file)
      end
    end
    
    send_file zipfile_name, :type=>"application/zip", :x_sendfile=>true
  end

  def show_hidden_comments
    assignment = Assignment.find(params[:assignment_id])
    for submission in assignment.submissions
      for comment in submission.comments
        if comment.hidden && !comment.visible
          comment.update_attributes(hidden: false)
        end
      end
    end
    redirect_to assignment_path(assignment)
  end

  def hide_hidden_comments
    assignment = Assignment.find(params[:assignment_id])
    for submission in assignment.submissions
      for comment in submission.comments
        if !comment.hidden && !comment.visible
          comment.update_attributes(hidden: true)
        end
      end
    end
    redirect_to assignment_path(assignment)
  end
  
end
