require 'sinatra'
require 'RMagick'

get "/:width/:height" do
  @image = File.open('public/dog01.jpg')

  width = params[:width].to_i
  height = params[:height].to_i

  img = Magick::Image.read('public/dog01.jpg').first
  puts "img is: #{img}"

  thumbnail = img.thumbnail( width, height )
  thumbnail.format = 'png'

  content_type 'image/png'
  thumbnail.to_blob
end


def get_uuid
  `uuidgen`.strip
end

