module SubmissionsHelper
  # see if a submission is late
  def is_late(submission, assignment)
    if has_due_date(assignment)
      submission.created_at > assignment.due_date
    else
      return false
    end
  end
  # see if a submission is late but has an extension
  def is_late_with_extension(submission, assignment)
    if has_due_date(assignment)
      if is_late(submission, assignment) && !assignment.latest_extension_for(submission.user).blank?
        return submission.created_at <= assignment.latest_extension_for(submission.user).due_date
      end
    else
      return false
    end
  end
  # see if a submission is late and does not have an extension
  def is_late_without_extension(submission, assignment)
    if has_due_date(assignment)
      is_late(submission, assignment) && assignment.latest_extension_for(submission.user).blank?
    else
      return false
    end
  end
  
  private
  
  def has_due_date(assignment)
    return assignment.due_date
  end
end
