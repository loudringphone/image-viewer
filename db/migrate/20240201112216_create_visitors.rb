class CreateVisitors < ActiveRecord::Migration[7.1]
  def change
    create_table :visitors do |t|
      t.string :cookie
      t.string :pathname
      t.integer :image_last_viewed
      t.datetime :last_seen_at

      t.timestamps
    end
  end
end
