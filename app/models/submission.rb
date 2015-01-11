class Submission < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :comments
  has_one :test_result
  
  include CompileHaskell
  
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
  
  def compile_haskell
    if self.assignment.tests
      tests = self.assignment.tests.split("\n")
    end

    run(self, tests)
  end
  handle_asynchronously :compile_haskell, :run_at => Proc.new { Time.now }
  
  def reviewed_by?(user)
    !self.comments.select{|c| c.user ==  user}.empty?
  end
  
  def comments_by(user)
    self.comments.select{|c| c.user ==  user}
  end
end
