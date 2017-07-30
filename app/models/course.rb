class Course < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_and_belongs_to_many :students
  has_and_belongs_to_many :convenors
  has_and_belongs_to_many :users
  has_many :tutors

  validates :name, presence: true
  validates :code, presence: true

  scope :latest, -> { order(created_at: :desc) }

  def users_to_csv(course_users)
    out_string = ""
    for u in course_users
      out_string += u.uid + "\n"
    end
    out_string
  end

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
    (self.students + User.all.select{|u| u.role.to_h[self.id.to_s] == "Student"}).uniq
  end
  
  def get_tutor_roles
    (self.tutors + User.all.select{|u| u.role.to_h[self.id.to_s] == "Tutor"}).uniq
  end

  def get_convenor_roles
    (self.convenors + User.all.select{|u| u.role.to_h[self.id.to_s] == "Convenor"}).uniq
  end

end
