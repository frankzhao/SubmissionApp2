class Course < ActiveRecord::Base
  has_many :labgroups
  has_many :assignments
  has_and_belongs_to_many :users

end
