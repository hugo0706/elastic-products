class ProductsController < ApplicationController
  def index
    @filters = ElasticServices::KeywordFilterService.get_filters_for(Product)
    @order_bys = Product::SORTING_FIELDS.map { |field| {field => ['asc', 'desc']} }
  end
end
