class RemoveColumnsFromVisitors < ActiveRecord::Migration[7.1]
  def change
    remove_column :visitors, :pathname, :string
    remove_column :visitors, :image_last_viewed, :integer
    remove_column :visitors, :last_seen_at, :datetime
  end
end
