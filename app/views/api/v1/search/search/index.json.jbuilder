json.array!(@results) do |product|
  json.partial! "/api/v1/search/product", product: product
end
