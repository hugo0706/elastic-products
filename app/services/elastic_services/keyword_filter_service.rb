module ElasticServices
  class KeywordFilterService
    
    def self.get_filters_for(klass)
      form_filtering_fields = klass::FORM_FILTERING_FIELDS
      
      return unless form_filtering_fields
      
      @search_definition = {
        "size": 0,
        "aggs": {}
      }
  
      form_filtering_fields.each do |field|
        @search_definition[:aggs]["#{field}_aggregation"] = {
            "terms": {
              "field": field,
              "order": { "_key": "asc" },
              "size": 10000 
            }
          }
      end

      results = klass.__elasticsearch__.search(@search_definition)
  
      values = {}
  
      form_filtering_fields.each do |field|
        filter_fields = results.response["aggregations"]["#{field}_aggregation"]["buckets"]
        values[field] =
          filter_fields.map { |r| [ r[:key], r[:doc_count] ] }.to_h
      end
      
      values
    end
  end
end
