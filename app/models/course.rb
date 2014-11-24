class Course < ActiveRecord::Base
  has_many :groups, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_and_belongs_to_many :users
  has_many :tutors
  has_many :convenors
  has_many :students

  validates :name, presence: true
  validates :code, presence: true

  def users_to_csv(course_users)
    out_string = ""
    for u in course_users
      out_string += u.uid + "\n"
    end
    return out_string
  end

  def students_to_csv
    users_to_csv self.students
  end

  def tutors_to_csv
    users_to_csv self.tutors
  end

  def convenors_to_csv
    users_to_csv self.convenors
  end

end
