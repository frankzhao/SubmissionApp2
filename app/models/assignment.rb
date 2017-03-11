class Assignment < ApplicationRecord
  belongs_to :course
  has_many :submissions
  has_many :assignment_extensions, dependent: :destroy
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :lang, presence: true
  
  SUPPORTED_LANGUAGES = ["Haskell", "Ada", "Chapel", "ARM GNU"]
  LEXERS = ['haskell', 'ada', 'chapel', 'asm']
  
  def latest_extension_for(user)
    self.assignment_extensions.select{|x| x.user == user}.last
  end
  
  def finalised_submissions
    Submission.where(assignment_id: self.id, finalised: true)
  end
  
  def peer_review_submissions_for(user)
    Submission.where(peer_review_user_id: user.id, assignment_id: self.id)
  end
  
  def students
    (read_attribute(:students) + User.all.select{|u| u.role.to_h[self.course.id.to_s] == "Student"}).uniq
  end
  
  def lexer
    if self.lang == nil
      return 'text'
    else
      return Hash[SUPPORTED_LANGUAGES.zip(LEXERS)][self.lang]
    end

  end
end
