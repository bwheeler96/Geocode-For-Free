# This is GeocodeForFree

require 'rubygems'
require 'bundler'
Bundler.require

require "sinatra/activerecord"

# Models & Concerns
Dir['./models/*.rb'].each do |f| require f end

Dir['./models/concerns/*.rb'].each do |f| require f end

set :database, "sqlite3:///db/geocode.sqlite3"

class GeocodeForFree < Sinatra::Base

	get '/' do 
		haml :index
	end		

	get '/v1/geocode' do
		"Hello Again"
	end

  get '/v1/docs' do
    haml :docs
  end

  get '/applications' do
    "applications Index"
  end

  post '/applications' do
		"Create Application"
	end

	#namespace :v1 do
  #
	#	get '/geocode' do
	#		"Geocode"
	#	end
	#
	#end

end


