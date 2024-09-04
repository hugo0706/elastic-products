class ProductsController < ApplicationController
  def index
    @filters = ElasticServices::KeywordFilterService.get_filters_for(Product)
  end
end
