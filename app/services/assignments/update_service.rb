module Assignments
  class UpdateService < BaseService
    def initialize(course, opts)
      super(course, opts)
      @params = opts[:params]
      @assignment = opts[:assignment]
    end

    def execute
      ActiveRecord::Base.transaction do
        update_attributes
        update_folders
        @assignment
      end
    end

    private

    def update_folders
      old_folder = sanitize_str(@assignment.name)
      new_folder = sanitize_str(@params[:assignment_name])

      if old_folder != new_folder
        # Rename upload directories if assignment is renamed
        old_path = Rails.root.to_s + "/public/uploads/#{old_folder}"
        new_path = Rails.root.to_s + "/public/uploads/#{new_folder}"
        `mv #{old_path} #{new_path}`

        # Rename uploaded submissions
        @assignment.submissions.each do |submission|
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
    end

    def update_attributes
      date_due = Chronic.parse(@params[:date_due], :endian_precedence => [:little, :median])
      @assignment.update_attributes(
          :name => @params[:assignment_name],
          :due_date => date_due,
          :description => @params[:text],
          :tests => @params[:tests],
          :peer_review_enabled => @params[:assignment][:peer_review_enabled],
          :copy_path => @params[:assignment][:copy_path],
          :disable_compilation => @params[:assignment][:disable_compilation],
          :lang => @params[:assignment][:lang],
          :custom_compilation => @params[:assignment][:custom_compilation],
          :custom_command => @params[:assignment][:custom_command],
          :pdf_regex => @params[:assignment][:pdf_regex],
          :zip_regex => @params[:assignment][:zip_regex],
          :timeout => @params[:assignment][:timeout]
      )
    end
  end
end