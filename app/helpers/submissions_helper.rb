module SubmissionsHelper
  # see if a submission is late
  def is_late(submission, assignment)
    submission.created_at > assignment.due_date
  end
  # see if a submission is late but has an extension
  def is_late_with_extension(submission, assignment)
    if is_late(submission, assignment) && !assignment.latest_extension_for(submission.user).blank?
      return submission.created_at <= assignment.latest_extension_for(submission.user).due_date
    end
  end
  # see if a submission is late and does not have an extension
  def is_late_without_extension(submission, assignment)
    is_late(submission, assignment) && assignment.latest_extension_for(submission.user).blank?
  end
end
