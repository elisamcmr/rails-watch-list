class CreateListImages < ActiveRecord::Migration[7.1]
  def change
    create_table :list_images do |t|
      t.string :image_url
      t.references :list, null: false, foreign_key: true
      t.timestamps
    end
  end
end
