require 'sinatra'
require 'RMagick'
require 'newrelic_rpm'

set :port, 3010
set :bind, '127.0.0.1'

get "/" do

  erb :index
end

get "/:width/:height" do
  content_type 'image/png'

  width = params[:width].to_i
  height = params[:height].to_i

  image = nil
  while( image == nil ) do
    image = get_doggie_image( width, height )
  end

  image.to_blob
end

get "/g/:width/:height" do
  content_type 'image/png'

  width = params[:width].to_i
  height = params[:height].to_i

  image = nil
  while( image == nil ) do
    image = get_doggie_image( width, height )
  end

  image = image.quantize( 256, Magick::GRAYColorspace )

  image.to_blob
end

def get_doggie_image( width, height )
  img = get_random_image

  while( img.columns < width || img.rows < height ) do
    puts 'going for another'
    img = get_random_image
  end
  multiplier = 0.0

  puts "req: #{width}x#{height}"

  if width == height
    if img.columns < img.rows
      multiplier = width.to_f / img.columns 
    else
      multiplier = height.to_f / img.rows
    end
  elsif width < height
    multiplier = height.to_f / img.rows 
  else
    multiplier = width.to_f / img.columns 
  end

  puts "multiplier is: #{multiplier}"

  puts "orig: #{img.columns}x#{img.rows}"

  img = img.thumbnail( img.columns*multiplier, img.rows*multiplier )
  puts "thumb: #{img.columns}x#{img.rows}"
  img = img.crop( Magick::CenterGravity, width, height )

  puts "after: #{img.columns}x#{img.rows}"

  if img.columns != 1 || img.rows != 1
    return img
  else
    return nil
  end
end

def get_random_image
  all_pics = Dir.entries( 'images/' ).collect{ |f| f if f =~ /\.jpg/ }.compact
  
  Magick::Image.read( "images/#{all_pics[rand(all_pics.count)]}" ).first
end
