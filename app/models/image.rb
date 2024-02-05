class Image < ApplicationRecord
  broadcasts_to -> (image) { :images }

  mount_uploader :attachment, AttachmentUploader
  validates :title, presence: true, length: { maximum: 30 }
  validates :attachment, presence: true
  validates :description, presence: true


  def self.previous_image(created_at)
    where('created_at < ?', created_at).order(created_at: :desc).first
  end

  def self.next_image(created_at)
    where('created_at > ?', created_at).order(created_at: :asc).first
  end
end
