class Course < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :assignments, dependent: :destroy

  has_many :course_roles
  has_many :users, through: :course_roles

  validates :name, presence: true
  validates :code, presence: true

  scope :latest, -> { order(created_at: :desc) }

  def students_to_csv
    users_to_csv(get_student_roles)
  end

  def tutors_to_csv
    users_to_csv(get_tutor_roles)
  end

  def convenors_to_csv
    users_to_csv(get_convenor_roles)
  end
  
  def get_student_roles
    get_roles('student')
  end
  
  def get_tutor_roles
    get_roles('tutor')
  end

  def get_convenor_roles
    get_roles('convenor')
  end

  alias_method :students, :get_student_roles
  alias_method :tutors, :get_tutor_roles
  alias_method :convenors, :get_convenor_roles

  private

  def users_to_csv(users)
    users.pluck(:uid).join("\n")
  end

  def get_roles(role)
    User.where(id: CourseRole.where(course: self, role: role).pluck(:user_id))
  end
end
