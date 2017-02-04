class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :submission
  mount_uploader :attachment, AttachmentUploader
end
