class Notification < ApplicationRecord
  belongs_to :user

  validates :text, presence: true

  def self.create_and_distribute(text, link = nil, users)
  	n = Notification.create text: text, link: link
  	n.distribute_to_users(users)
  end

  def distribute_to_users(users)
  	users.each do |u|
  		u.notifications << self
  	end
  end

  def dismiss!
  	self.destroy
  end
end
