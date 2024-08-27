# frozen_string_literal: true

module Api
  module V1
    class SearchController < ApplicationController
      before_action :validate_params

      SORTING_FIELDS = %w(ratings no_of_ratings discount_price created_at )
      SORTING_ORDERS = %w(asc desc)
      PER_PAGE = [ 10, 25 ]

      def index
        params = permitted_params
        return unless params

        option_params = params[:options]
        options = {}
        if option_params
          options = {
            main_category: option_params[:mc],
            sub_category: option_params[:sc],
            ratings: option_params[:ratings],
            no_of_ratings: option_params[:n_ratings],
            actual_price: option_params[:a_price],
            sort: option_params[:sort]
          }
        end

        @results = Product.search(params[:query], page, per_page, options).results
      end

      private

      def page
        permitted_params[:page]
      end

      def per_page
        permitted_params[:per_page]
      end

      def permitted_params
        @permitted_params ||= params.require(:search)
                                    .permit(:query, :page, :per_page,
                                            options: [:mc, :sc, :ratings, :n_ratings, :a_price, sort: {}])
      end

      ParamValidationErrors = Struct.new(:value) do
        def +(other)
          self.value = self.value.empty? ? other : "#{value}\n#{other}"
          self
        end

        def to_s
          value
        end
      end

      def validate_params
        errors = ParamValidationErrors.new("")

        unless permitted_params[:page].to_i >= 0
          errors += "Page must be a positive integer"
        end

        unless PER_PAGE.include?(permitted_params[:per_page].to_i)
          errors += "Per_page must either 10 or 25 products"
        end
        unless SORTING_FIELDS.include?(permitted_params[:options][:sort].keys.first) ||
              SORTING_ORDERS.include?(permitted_params[:options][:sort].value.first)
          errors += "Sort must include a valid field #{SORTING_FIELDS})"\
                    " and valid sorting order #{SORTING_ORDERS}"
        end

        return if errors.value.empty?
        render json: { error: errors }, status: :bad_request
      end
    end
  end
end
