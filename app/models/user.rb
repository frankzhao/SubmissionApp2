class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:uid]

  has_and_belongs_to_many :courses
  belongs_to :labgroup
  has_many :submissions
  has_many :comments
  has_many :notifications
  has_many :extensions

  validates :uid, :uniqueness => {:case_sensitive => false},
    :format => { with: /u\d{7}/, message: "Your uni ID should be in the form uXXXXXXX"}

  def is_admin?
    self.type == "Admin"
  end

  def is_admin_or_convenor?
    self.type == "Admin" or self.type == "Convenor"
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

end
