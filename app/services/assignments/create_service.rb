module Assignments
  class CreateService < BaseService
    attr_accessor :assignment

    def initialize(course, opts)
      super(course, opts)
      @params = opts[:params]
      @assignment = nil
    end

    def execute
      create_assignment
      notify_users
      @assignment
    end

    private

    def create_assignment
      name = @params[:assignment_name]
      date_due = @params[:date_due]
      text = @params[:text]
      tests = @params[:tests]
      peer_review = @params[:assignment][:peer_review_enabled]
      copy_path = @params[:assignment][:copy_path]

      # Parse due date
      date_due = Chronic.parse(date_due, :endian_precedence => [:little, :median])
      @assignment = Assignment.create(
          :name => name,
          :due_date => date_due,
          :description => text,
          :kind => @params[:assignment][:kind],
          :tests => tests,
          :peer_review_enabled => peer_review,
          :copy_path => copy_path,
          :disable_compilation => @params[:assignment][:disable_compilation],
          :lang => @params[:assignment][:lang],
          :custom_compilation => @params[:assignment][:custom_compilation],
          :custom_command => @params[:assignment][:custom_command],
          :pdf_regex => @params[:assignment][:pdf_regex],
          :zip_regex => @params[:assignment][:zip_regex],
          :timeout => @params[:assignment][:timeout],
          :course_id => @course.id
      )
    end

    def notify_users
      Notification.create_and_distribute("New assignment: " + @assignment.name,
                                         Rails.application.routes.url_helpers.assignment_path(assignment), @course.users)
      ::Courses::AssignmentService.new(@course).execute
    end
  end
end