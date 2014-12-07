class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :comments
  
  def zipfile_path
    file_path + ".zip"
  end
  
  def plaintext_path
    file_path + ".txt"
  end
  
  def submission_path
    user = self.user
    id = self.id
    timestamp = self.created_at
    Rails.root.to_s + "/public/uploads/#{sanitize_str(assignment.name)}"
  end
  
  def file_path
    user = self.user
    id = self.id
    timestamp = self.created_at
    Rails.root.to_s + "/public/uploads/#{sanitize_str(assignment.name)}/" +
      user.uid + "_" +
      sanitize_str(user.full_name) + "_" +
      sanitize_str(assignment.name) + "_" +
      sanitize_str(id) + "_" +
      sanitize_str(timestamp)
  end
end
