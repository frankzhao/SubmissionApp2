class Labgroup < ActiveRecord::Base
  belongs_to :course
  has_many :users, through: :courses
end
