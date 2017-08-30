class Group < ApplicationRecord
  belongs_to :course

  has_many :group_roles
  has_many :users, through: :group_roles

  def get_student_roles
    course_id = self.course.id.to_s
    (self.students + User.all.select{|u| u.role.to_h[course_id] == "Student" && u.group_id == self.id }).uniq
  end
end
