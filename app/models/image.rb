class Image < ApplicationRecord
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

  def add_viewer(user_id)
    update!(current_views: current_views.push(user_id).uniq)
  end

  def remove_viewer(user_id)
    update!(current_views: current_views.reject { |id| id == user_id })
  end
end
