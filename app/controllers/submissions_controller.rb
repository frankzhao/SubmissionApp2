class SubmissionsController < ApplicationController
  include SubmissionsHelper
  include ActionView::Helpers::TextHelper

  before_action :require_logged_in
  respond_to :html
  
  require 'zip'

  def new
    @submission = Submission.new
    @assignment = Assignment.find(params[:assignment_id])
    @most_recent_submission = current_user.recent_submission_for(@assignment)
    @course = @assignment.course

    unless current_user.relationship_to(@course) || current_user.role.include?(@course.id.to_s) || current_user.is_staff?
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
      unless @assignment.disable_compilation
        if @assignment.custom_compilation
          out = @submission.compile_custom
        else
          if @assignment.lang == "Haskell" || @assignment.lang.nil?
            out = @submission.compile_haskell
          elsif @assignment.lang == "Ada"
            out = @submission.compile_ada
          elsif @assignment.lang == "Chapel"
            out = @submission.compile_chapel
          elsif @assignment.lang = "ARM GNU"
            out = @submission.compile_arm_gnu
          end
        end
      end
      
    elsif @assignment.kind == 'zipfile'
      uploaded_zip = params[:submission][:zipfile]
      zip_path = @submission.zipfile_path
      
      File.open(zip_path, 'wb') do |file|
        file.write(uploaded_zip.read)
      end
      
      if @assignment.custom_compilation
        out = @submission.compile_custom
      end
    end
    
    # Copy if path is specified
    if @assignment.copy_path.present?
      folder = @assignment.copy_path.split("/")[0...-1].join("/")
      FileUtils.mkdir_p parse_copy_path(folder, @submission)
      FileUtils.cp(@submission.plaintext_path, parse_copy_path(@assignment.copy_path, @submission))
    end
    
    redirect_to submission_path(@submission)
  end

  def show
    @submission = Submission.find(params[:id])
    require_submission_privileges(@submission)
    @assignment = @submission.assignment
    if @assignment.kind == 'zip'
      # Retrieve file list
      @contents = []

      regex = @assignment.zip_regex
      if regex.to_s.empty?
        regex = Regexp.new("$^")
      else
        regex = Regexp.new(regex)
      end

      begin
        Zip::File.open(@submission.zipfile_path) do |zipfile|
          for file in zipfile
            if (file.name !~ /MACOSX|DS_Store/) && (file.name !~ regex)
              @contents << file.name
            end
          end
        end
      rescue
        # Leave contents empty
      end
    end
    
    if @submission.kind == "plaintext"
      @plaintext = Pygments.highlight(@submission.plaintext, lexer: @assignment.lexer,
        options: {linenos: 'table'})
    end
    @comment = Comment.new
    
    if (@submission.kind == "plaintext") && @submission.test_result.nil?
      render
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          count = 0
          while @submission.test_result.nil? && count < 15
            @submission = Submission.find(@submission.id)
            count = count + 1
            sleep(2)
          end
          WebsocketRails[:submissions].trigger 'compile', {result: (@submission.test_result.result)}
        end
      end
    end
  end
  
  def update
    @submission = Submission.find(params[:id])
    
    if @submission.kind == "zipfile"
      old_path = @submission.zipfile_path
    end
    
    @submission.update_attributes(submission_params)
    
    # Rename
    if @submission.kind == "zipfile"
      `mv #{old_path} #{@submission.zipfile_path}`
    end
    
    redirect_to submission_path(@submission)
  end

  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy
    redirect_to assignment_path(@submission.assignment)
  end
  
  def finalise
    @submission = Submission.find(params[:id])
    @submission.update_attributes(finalised: true)
    @assignment = @submission.assignment

    # Peer reviews
    if @assignment.peer_review_enabled && @assignment.finalised_submissions.length > 1
      peer_submission = @assignment.finalised_submissions.select{|s| (s.user != current_user) && (s.peer_review_user_id.nil?)}.last
      if peer_submission
        peer_submission.peer_review_user_id = current_user.id
        peer_submission.save
        # Notify
        Notification.create_and_distribute("New submission to review for " + @assignment.name, submission_path(peer_submission), [current_user])
      end
    end
    
    redirect_to submission_path(@submission)
  end
  
  def download
    @submission = Submission.find(params[:id])
    if (@submission.user == current_user) || current_user.is_staff?
      if @submission.assignment.kind == "zip"
        send_file @submission.zipfile_path, :type=>"application/zip", :x_sendfile=>true
      else
        send_file @submission.plaintext_path, :type=>"application/plaintext", :x_sendfile=>true
      end
    else
      if @submission.assignment.kind == "zip"
        send_file @submission.zipfile_path, :type=>"application/zip",
          :x_sendfile=>true, filename: "Main.txt"
      else
        send_file @submission.plaintext_path, :type=>"application/plaintext",
          :x_sendfile=>true, filename: "Main.txt"
      end
    end
  end
  
  def pdf
    @submission = Submission.find(params[:id])
    send_file @submission.make_pdf, :type=>"application/pdf", :x_sendfile=>true
  end
  
  def pdf_comments
    @submission = Submission.find(params[:id])
    send_file @submission.make_pdf_with_comments, :type=>"application/pdf", :x_sendfile=>true
  end
  
  # Check for compilation results
  def check_result
    ActiveRecord::Base.connection_pool.with_connection do
      Submission.uncached do
        @submission = Submission.find(params[:id])
        if (@submission.kind == "plaintext") && @submission.test_result.nil?
          count = 0
          while @submission.test_result.nil? && count < 10
            @submission = Submission.find(@submission.id)
            count = count + 1
            sleep(2)
          end
          render :json => @submission.test_result.to_json, :status => 200
        else
          render :json => {result: false}, :status => 200
        end
      end
    end
  end
  
  def contents
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
    
    if @assignment.kind != "zip"
      flash_message :error, "Submission type is incompatible with viewer."
      redirect_to :back
      return
    end
    regex = @assignment.zip_regex
    if regex.to_s.empty?
      regex = Regexp.new("$^")
    else
      regex = Regexp.new(regex)
    end
    @files = unzip_to_hash(@submission.zipfile_path, regex)
    @contents = {}
    for filename in @files.keys
      @contents[filename] = Pygments.highlight(
        @files[filename].force_encoding("UTF-8"),
        lexer: (@assignment.lang.nil? ? "Haskell" : @assignment.lang.downcase),
        options: {linenos: 'table'}
      )
    end
  end
  
  private
  
  def submission_params
    params.require(:submission).permit(:created_at)
  end
  
end
