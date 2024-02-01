class CreateImages < ActiveRecord::Migration[7.1]
  def change
    create_table :images do |t|
      t.string :title
      t.string :attachment
      t.datetime :uploaded_time

      t.timestamps
    end
  end
end
