class CourseRole < ApplicationRecord

  belongs_to :user
  belongs_to :course

  VALID_ROLES = %w{convenor tutor student}.freeze

  validates_presence_of :user_id, :course_id, :role
  validates_inclusion_of :role, in: VALID_ROLES
  validates_uniqueness_of :user_id, scope: [ :course_id ]

end
