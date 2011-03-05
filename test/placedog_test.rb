begin 
  # this only works for 1.9
  require_relative '../placedog.rb'
rescue NameError
  # must be using 1.8
  require File.expand_path('../placedog.rb', __FILE__)
end

require 'test/unit'
require 'rack/test'

class PlacedogTest < Test::Unit::TestCase
  include Rack::Test::Methods

  IMAGE_FILETYPE = 'image/png'

  def app
    Placedog
  end
  
  def test_my_default
    get '/'
    assert last_response.ok?
  end

  def test_get_picture
    get '/300/400'
    assert_equal IMAGE_FILETYPE, last_response.content_type
  end

  def test_abnormal_dimensions
    width = 4272
    height = 2848

    get "/#{width}/#{height}"
    assert_equal IMAGE_FILETYPE, last_response.content_type
  end

  def test_get_many_pictures
    (1..20).each do |i|
      width = rand 2000
      height = rand 2000

      get "/#{width}/#{height}"
      assert_equal IMAGE_FILETYPE, last_response.content_type
    end
  end
end
