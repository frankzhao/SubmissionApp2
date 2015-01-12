class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :submission
  mount_uploader :attachment, AttachmentUploader
end
