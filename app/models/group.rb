class Group < ActiveRecord::Base
  belongs_to :course
  has_many :users
  has_many :students
  has_and_belongs_to_many :convenors
  belongs_to :tutor
end
