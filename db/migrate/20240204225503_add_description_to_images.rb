class AddDescriptionToImages < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :description, :text
  end
end
