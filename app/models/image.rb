class Image < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader
  validates :title, presence: true
  validates :attachment, presence: true
end
