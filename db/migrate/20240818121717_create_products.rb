class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :main_category
      t.string :sub_category
      t.string :image
      t.string :link
      t.float :ratings, default: 0.0, precision: 3, scale: 2
      t.integer :no_of_ratings, default: 0
      t.float :discount_price, default: 0.0, scale: 2
      t.float :actual_price, default: 0.0, scale: 2

      t.timestamps
    end
  end
end
