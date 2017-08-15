class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:uid]

  has_many :course_roles
  has_many :courses, through: :course_roles

  has_many :submissions
  has_many :comments
  has_many :notifications
  has_many :extensions
  has_and_belongs_to_many :assignments
  
  serialize :role

  validates :uid, :uniqueness => true,
    :format => { with: /u\d{7}/, message: "Your uni ID should be in the form uXXXXXXX"}

  include UserAssignmentRelations

  def groups
    Group.where(id: self.group_id)
  end

  def submissions_for(a)
    Submission.where(user_id: self.id, assignment_id: a.id)
  end

  def recent_submission_for(a)
    self.submissions.select { |s| s.user == self and s.assignment == a}.last
  end

  # == Helper methods ==

  def full_name
    (self.firstname.to_s + " " + self.surname.to_s).encode("ISO-8859-1").to_ascii
  end
  
  def firstname
    read_attribute(:firstname).to_s.encode("ISO-8859-1").to_ascii
  end
  
  def surname
    read_attribute(:surname).to_s.encode("ISO-8859-1").to_ascii
  end

  def is_admin?
    self.type == "Admin"
  end
  
  def is_tutor?(course)
    self.role.to_h[course.id.to_s] == "Tutor" #|| self.type == "Tutor"
  end

  def is_convenor?
    self.type == "Convenor" || self.role.to_h.values.include?("Convenor")
  end
  
  def is_convenor_for_course?(course)
    self.type == "Convenor" || self.role.to_h[course.id.to_s] == "Convenor"
  end

  def is_admin_or_convenor?
    self.type == "Admin" || self.is_convenor?
  end

  def is_staff?
    (self.is_admin_or_convenor? || self.type == "Tutor")  || self.role.to_h.values.include?("Tutor")
  end
  
  def is_staff_for_course?(course)
    self.is_admin_or_convenor? || self.is_tutor?(course)
  end
  
  def is_owner_or_staff?(resource)
    self.is_staff? || resource.user == self
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if uid = conditions.delete(:uid)
      where(conditions).where(["lower(uid) = :value", { :value => uid.downcase }]).first
    else
      where(conditions.first)
    end
  end

  def self.find_or_create_by_uid(uid)
    user = User.find_by_uid(uid)

    if user
      user
    else
      ldap_user = ::Ldap::LookupService.new(uid).execute
      User.create(:uid => s, :firstname => ldap_user[:given_name].force_encoding('ISO-8859-1'), :surname => ldap_user[:surname].force_encoding('ISO-8859-1'))
    end
  end

  def add_to_course_as_student(course)
    add_to_course(course, "Student")
  end

  def add_to_course_as_convenor(course)
    add_to_course(course, "Convenor")
  end

  def add_to_course_as_tutor(course)
    add_to_course(course, "Tutor")
  end

  def remove_from_course(course)
    hash_id = course.id.to_s
    # Remove from course
    courses.delete(course)
    begin
      course.students.delete(s) # not sure why we are doing it again
    rescue ActiveRecord::RecordNotFound
      # ignored
    end

    s.update_attributes(role: role.to_h.delete(hash_id))
  end

  def password_required?
    # override blank password limitation
    false
  end

  private

  def add_to_course(course, type)
    hash = { "#{course.id}" => type}
    update_attributes(role: role.to_h.merge(hash))
    courses << c unless courses.include?(c)
  end

end
