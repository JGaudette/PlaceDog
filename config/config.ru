require 'sinatra'

Sinatra::Base.set(:env, 'production')
Sinatra::Base.set(:run, 'false')

require '/home/placedog/current/placedog.rb'
run Sinatra.application

