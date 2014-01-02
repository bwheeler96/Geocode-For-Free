# This is GeocodeForFree

require 'sinatra'

require "sinatra/activerecord"

set :database, "sqlite3:///db/geocode.sqlite3"

class GeocodeForFree < Sinatra::Base

	get '/' do 
		haml :index
	end		

	get '/geocode' do 
		"Hello Again"
	end

  get '/applications' do
    "applications Index"
  end

	post '/applications' do 
		"Create Application"
	end

	namespace :v1 do 

		get '/geocode' do 
			"Geocode"
		end
	
	end

end


