# This is GeocodeForFree

require 'rubygems'
require 'bundler'
Bundler.require

#require "sinatra/activerecord"

# Models & Concerns
Dir['./models/*.rb'].each do |f| require f end

Dir['./models/concerns/*.rb'].each do |f| require f end

include Geocode

set :database, "sqlite3:///db/geocode.sqlite3"
enable :sessions

class GeocodeForFree < Sinatra::Base

  register Sinatra::Flash
  #helpers Sinatra::

	get '/' do
		haml :index
	end		

	get '/v1/geocode' do
    georaw = Array(params[:locations])
    @geodata = batch_geocode(georaw)
    content_type :json
    @geodata.to_json
	end

  get '/v1/docs' do
    haml :docs
  end

  get '/applications' do
    "applications Index"
  end

  get '/applications/:confirmation/confirm' do
    @application = Application.find_by_confirmation(params[:confirmation])
    @application.confirm!
    flash[:success] = 'Thanks. You may now use your API key for Geocoding!'
    redirect '/', success: 'Thanks. You may now use your API key for Geocoding!'
  end

  post '/applications' do
		begin
      @application = Application.create!(params[:application])
      Pony.mail(
        to: params[:application][:email],
        from: 'brian@geocodeforfree.com',
        subject: 'Start geocoding for free!',
        html_body: haml(:welcome, layout: false)
      )
      'Create Application'
    rescue => e
      raise e if GeocodeForFree.development?
      puts e
      'There was an error making your API key.'
    end
	end

	#namespace :v1 do
  #
	#	get '/geocode' do
	#		"Geocode"
	#	end
	#
	#end

end


