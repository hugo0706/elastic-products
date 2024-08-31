# frozen_string_literal: true

require 'elasticsearch/model'

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1, number_of_replicas: 0 } do
      mapping do
        indexes :name
        indexes :main_category,type: :keyword
        indexes :sub_category, type: :keyword
        indexes :image, type: :keyword, index: false
        indexes :link, type: :keyword, index: false
        indexes :no_of_ratings, type: :integer
        indexes :discount_price, type: :float
        indexes :actual_price, type: :float
        indexes :es_timestamp, type: :date
      end
    end

    def self.search(query, page = 0, per_page = 20, options = {})
      @search_definition = {
        from: page*per_page,
        size: per_page,
        query: {
          bool: {
          }
        }
      }

      if query.present?
        @search_definition[:query] = {
          bool: {
            must: [
              { multi_match: {
                  query: query,
                  fields: ['name^10', 'main_category^2', 'sub_category'],
                  operator: 'and'
                }
              }
            ]
          }
        }
      else
         @search_definition[:query][:bool][:must] = { match_all: {} }
      end

      if options[:main_category]
        @search_definition[:query][:bool][:filter] ||= []
        @search_definition[:query][:bool][:filter] << 
          { term: { "main_category": options[:main_category] } }
      end

      if options[:sub_category]
        @search_definition[:query][:bool][:filter] ||= []
        @search_definition[:query][:bool][:filter] << 
          { term: { "sub_category": options[:sub_category] } }
      end
      
      if options[:actual_price]
        @search_definition[:query][:bool][:filter] ||= []
        @search_definition[:query][:bool][:filter] <<
          { range: {
            actual_price: { 
              gte: options[:actual_price][:gte],
              lte: options[:actual_price][:lte]
              } 
            } 
          }
      end
      
      if options[:ratings]
        @search_definition[:query][:bool][:filter] ||= []
        @search_definition[:query][:bool][:filter] <<
          { range: {
            ratings: { 
              gte: options[:ratings][:gte],
              lte: options[:ratings][:lte]
              } 
            } 
          }
      end
      

      if options[:sort]
        @search_definition[:sort] = options[:sort].to_hash
      end

      __elasticsearch__.search(@search_definition)
    end

    def as_indexed_json(options = {})
      as_json.merge("es_timestamp" => es_timestamp)
    end

    def es_timestamp
      Time.now
    end
  end
end
