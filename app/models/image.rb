class Image < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader
  validates :title, presence: true, length: { maximum: 30 }
  validates :attachment, presence: true
end
