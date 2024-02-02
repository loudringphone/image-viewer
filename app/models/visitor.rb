class Visitor < ApplicationRecord
  validates :cookie, presence: true

  scope :viewed_image_within_5_seconds, ->(image_id) {
    where("last_seen_at > ? AND image_last_viewed = ?", 5.seconds.ago, image_id)
  }
end
