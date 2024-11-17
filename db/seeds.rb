# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'open-uri'
require 'json'

# 1. Clean the database 🗑️
puts 'Cleaning database...'
Movie.destroy_all

# 2. Create the instances 🏗️
puts 'Creating movies...'

url = "https://tmdb.lewagon.com/movie/top_rated"

movies_serialized = URI.open(url).read
movies = JSON.parse(movies_serialized)

movies['results'].each do |movie_data|
  Movie.create!(
    title: movie_data['title'],
    overview: movie_data['overview'],
    poster_url: "https://image.tmdb.org/t/p/w500#{movie_data['poster_path']}",
    rating: movie_data['vote_average'].round(1)
  )
end

puts "#{Movie.count} movies created"

puts "Clearing existing lists..."
List.destroy_all

puts "Creating new lists with images from Cloudinary..."

lists = [
  { name: "Classics", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837759/classics_mewstq.avif" },
  { name: "Family", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837760/family_w9o50f.jpg" },
  { name: "Comedy", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837208/comedy_orz7wh.jpg" },
  { name: "Romance", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837760/romance_fqcoya.jpg" },
  { name: "Thriller", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837760/thriller_hythtq.jpg" },
  { name: "Horror", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837130/scariest-horror-movies-it-stephen-king-2x1-bn-220617-e38851_jpasfs.webp" },
  { name: "Sci-Fi/Fantasy", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837760/fantasy_brlei9.jpg" },
  { name: "Animation", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837759/animation_fzfvk1.jpg" },
  { name: "Musicals", image_url: "https://res.cloudinary.com/dtfkb3szp/image/upload/v1731837760/musicals_lzcgzq.jpg" },
]

lists.each do |list_data|
  list = List.create!(name: list_data[:name])

  # Attaching the image from a Cloudinary URL using Active Storage and open-uri
  file = URI.open(list_data[:image_url])
  list.photo.attach(io: file, filename: "#{list_data[:name].parameterize}_image.jpg", content_type: 'image/jpg')

  puts "Created list: #{list.name} with an image from Cloudinary"
end

puts "Seeding complete!"
