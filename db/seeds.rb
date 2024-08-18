# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'csv'

AMAZON_SEED_PATH="./db/seeds/amazon/"

def parse_number(number)
  return 0.0 unless number
  number.gsub("₹", "").gsub(',', '').to_f
end

Dir.each_child(AMAZON_SEED_PATH) do |file|
  headers = nil

  File.open(AMAZON_SEED_PATH + file, 'r') do |file|
    headers = CSV.parse_line(file.readline)
    headers = Hash[headers.map.with_index { |element, index| [ element.to_sym, index ] }]
  end

  CSV.foreach(AMAZON_SEED_PATH + file).with_index do |row, index|
    next if index == 0
    begin
      ActiveRecord::Base.transaction do
        data = {
          name: row[headers[:name]],
          main_category:  row[headers[:main_category]],
          sub_category:   row[headers[:sub_category]],
          image:          row[headers[:image]],
          link:           row[headers[:link]],
          ratings:        parse_number(row[headers[:ratings]]),
          no_of_ratings:  parse_number(row[headers[:no_of_ratings]]),
          discount_price: parse_number(row[headers[:discount_price]]),
          actual_price:   parse_number(row[headers[:actual_price]])
        }
        Product.create!(**data)
      end
    rescue StandardError => e
      puts "Error while seeding db with #{file} \n #{e.message}"
    end
  end
end
