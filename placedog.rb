require 'sinatra'
require 'RMagick'

get "/:width/:height" do
  content_type 'image/png'

  width = params[:width].to_i
  height = params[:height].to_i

  image = get_doggie_image( width, height )

  image.to_blob
end


def get_doggie_image( width, height )
  img = Magick::Image.read('public/dog01.jpg').first


  if width < height
    multiplier = height.to_f / img.rows 

    img = img.thumbnail( img.columns*multiplier, img.rows*multiplier )
    img = img.crop( Magick::CenterGravity, width, height )

  else
    multiplier = width.to_f / img.columns 

    img = img.thumbnail( img.columns*multiplier, img.rows*multiplier )
    img = img.crop( Magick::CenterGravity, width, height )
  end

  return img
end

