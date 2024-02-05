class AddCurrentViewsToImages < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :current_views, :integer, default: 0
  end
end
