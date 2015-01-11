class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions
  has_many :assignment_extensions, dependent: :destroy
  has_many :users

  validates :name, presence: true
  
  def latest_extension_for(user)
    self.assignment_extensions.select{|x| x.user == user}.last
  end
  
  def finalised_submissions
    self.submissions.select{|s| s.finalised}
  end
  
  def peer_review_submissions_for(user)
    self.submissions.select{|s| s.peer_review_user_id == user.id}
  end
end
