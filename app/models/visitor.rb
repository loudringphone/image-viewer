class Visitor < ApplicationRecord
  validates :cookie, presence: true

  scope :viewed_image_within_last_minute, ->(image_id) {
    where("last_seen_at > ? AND image_last_viewed = ?", 1.minutes.ago, image_id)
  }
end
