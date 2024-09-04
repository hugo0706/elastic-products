class Product < ApplicationRecord
  include Searchable
  
  FORM_FILTERING_FIELDS = %w(main_category sub_category)
end
