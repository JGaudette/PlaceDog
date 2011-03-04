require 'sinatra'
require 'RMagick'
require 'newrelic_rpm'

Pic = Struct.new( :image, :width, :height )

def preload_pics
  puts "Preloading pics"
  images = []

  Dir.entries( 'images/' ).collect{ |f| f if f =~ /\.jpg/ }.compact.each do |pic|
    mag = Magick::Image.read( "images/#{pic}" ).first
    p = Pic.new( mag, mag.columns, mag.rows )
    images.push p
  end

  puts "Pics found: #{images.count}"
  return images
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
  return PICS[rand(PICS.count)].image
end

PICS = preload_pics
puts "#{PICS} now has #{PICS.count}"
MAX_WIDTH  = 4272
MAX_HEIGHT = 2848

get "/" do

  erb :index
end

get "/:width/:height" do
  width = params[:width].to_i
  height = params[:height].to_i

  if not request_precheck( width, height )
    "Invalid width or height"
  else
    content_type 'image/png'

    image = nil
    while( image == nil ) do
      image = get_doggie_image( width, height )
    end

    image.to_blob
  end
end

get "/g/:width/:height" do
  width = params[:width].to_i
  height = params[:height].to_i

  if not request_precheck( width, height )
    "Invalid width or height"
  else
    content_type 'image/png'


    image = nil
    while( image == nil ) do
      image = get_doggie_image( width, height )
    end

    image = image.quantize( 256, Magick::GRAYColorspace )

    image.to_blob
  end
end

def request_precheck( width, height )
  if width > MAX_WIDTH or height > MAX_HEIGHT
    return false
  end

  return true
end
