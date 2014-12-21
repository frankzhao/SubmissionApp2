class SubmissionsController < ApplicationController
  before_filter :require_logged_in
  respond_to :html

  def new
    @submission = Submission.new
    @assignment = Assignment.find(params[:assignment_id])
    @most_recent_submission = current_user.recent_submission_for(@assignment)
    @course = @assignment.course
    
    unless current_user.relationship_to @course
      flash_message :error, "You must be enrolled in the course to create a new submission."
      redirect_to '/'
      return
    end
    
    if @assignment.kind == "plaintext"
      render 'new_plaintext'
    elsif @assignment.kind = "zip"
      render 'new_zip'
    end
  end

  def create
    @assignment = Assignment.find(params[:assignment_id])
    if @assignment.kind == 'plaintext'
      @submission = Submission.new(kind: "plaintext", plaintext: params[:plaintext])
    elsif @assignment.kind = 'zipfile'
      @submission = Submission.new(kind: "zipfile")
    end
    
    current_user.submissions << @submission
    @submission.user = current_user
    @assignment.submissions << @submission
    @submission.assignment = @assignment
    
    # Write files to disk
    path = @submission.submission_path
    system "mkdir -p #{path}"
    if @assignment.kind == 'plaintext'
      file_path = @submission.plaintext_path
      
      File.open(file_path, 'wb') do |file|
        file.write(params[:plaintext])
      end
      
      # Run tests
      out = @submission.compile_haskell
      
    elsif @assignment.kind == 'zipfile'
      uploaded_zip = params[:submission][:zipfile]
      zip_path = @submission.zipfile_path
      
      File.open(zip_path, 'wb') do |file|
        file.write(uploaded_zip.read)
      end
    end
    
    redirect_to assignment_path(@assignment)
  end

  def show
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
  end

  def index
  end

  def destroy
  end
  
  def finalise
    @submission = Submission.find(params[:id])
    @submission.update_attributes(finalised: true)
    redirect_to submission_path(@submission)
  end
end
