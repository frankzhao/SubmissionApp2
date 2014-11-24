class Group < ActiveRecord::Base
  belongs_to :course
  has_many :students
  belongs_to :tutor
end
