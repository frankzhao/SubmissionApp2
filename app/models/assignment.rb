class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions
  has_many :assignment_extensions
  has_many :users

  validates :name, presence: true
  validates :due_date, presence: true
  
  def latest_extension_for(user)
    self.assignment_extensions.select{|x| x.user == user}.last
  end
end
