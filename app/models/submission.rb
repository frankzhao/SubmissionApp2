class Submission < ActiveRecord::Base
  belongs_to :assignment
  has_many :comments
end
