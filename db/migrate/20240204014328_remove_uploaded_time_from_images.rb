class RemoveUploadedTimeFromImages < ActiveRecord::Migration[7.1]
  def change
    remove_column :images, :uploaded_time, :datetime
  end
end
