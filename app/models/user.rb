class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:uid]

  validates :uid, :uniqueness => {:case_sensitive => false},
    :format => { with: /u\d{7}/, message: "Your uni ID should be in the form uXXXXXXX"}

  #attr_accessor :uid

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
