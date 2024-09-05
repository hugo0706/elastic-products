class Product < ApplicationRecord
  include Searchable
  
  FORM_FILTERING_FIELDS = %w(main_category sub_category)
  SORTING_FIELDS = %w(ratings no_of_ratings discount_price actual_price)
end
