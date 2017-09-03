class Group < ApplicationRecord
  belongs_to :course

  has_many :group_roles
  has_many :users, through: :group_roles

  def get_student_roles
    get_role('student')
  end

  def get_tutor_roles
    get_role('tutor')
  end

  alias_method :students, :get_student_roles
  alias_method  :tutors, :get_tutor_roles

  def get_role(role)
    user_ids = group_roles.where(group: self, role: role).pluck(:user_id)
    User.where(id: user_ids)
  end
end
