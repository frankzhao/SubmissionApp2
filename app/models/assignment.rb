class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions
  has_many :assignment_extensions, dependent: :destroy
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :lang, presence: true
  
  SUPPORTED_LANGUAGES = ["Haskell", "Ada", "Chapel", "Custom"]
  
  def latest_extension_for(user)
    self.assignment_extensions.select{|x| x.user == user}.last
  end
  
  def finalised_submissions
    Submission.where(assignment_id: self.id, finalised: true)
  end
  
  def peer_review_submissions_for(user)
    Submission.where(peer_review_user_id: user.id, assignment_id: self.id)
  end
end
