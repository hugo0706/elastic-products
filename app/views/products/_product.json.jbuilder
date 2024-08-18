json.extract! product, :id, :name, :main_category, :sub_category, :image, :link, :ratings, :no_of_ratings, :discount_price, :actual_price, :created_at, :updated_at
json.url product_url(product, format: :json)
