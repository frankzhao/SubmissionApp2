class Course < ActiveRecord::Base
  has_many :labgroups
  has_many :assignments
  has_and_belongs_to_many :users
  has_many :tutors
  has_many :convenors
  has_many :students

  def url
    '/courses/' + self.id.to_s
  end

end
