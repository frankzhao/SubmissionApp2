class GroupRole < ApplicationRecord
  belongs_to :user
  belongs_to :group

  VALID_ROLES = %w{convenor tutor student}.freeze

  validates_presence_of :user_id, :group_id, :role
  validates_inclusion_of :role, in: VALID_ROLES
  validates_uniqueness_of :user_id, scope: [ :group_id ]
end
