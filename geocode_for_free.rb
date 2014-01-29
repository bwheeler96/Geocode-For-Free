# This is GeocodeForFree

# Explicit requires
require 'rubygems'
require 'bundler'
require 'sinatra/redirect_with_flash'

# Bundler
Bundler.require

# Models & Concerns
Dir['./models/*.rb'].each do |f| require f end

Dir['./models/concerns/*.rb'].each do |f| require f end

# The heart of the project
include Geocode

set :database, "sqlite3:///db/geocode.sqlite3"

class GeocodeForFree < Sinatra::Base

  enable :sessions

	get '/' do
    #flash.now[:success] = 'Fun!'
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

  get '/applications/:confirmation/confirm' do
    @application = Application.find_by_confirmation(params[:confirmation])
    @application.confirm!
    redirect '/?' + { success: 'Thanks. You may now use your API key for Geocoding!' }.to_query
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
      redirect '/?' + { success: 'Thanks for signing up! Check your email to confirm your account and receive your API key.' }.to_query
    rescue => e
      #raise e if GeocodeForFree.development?
      puts e
      redirect '/?' + { alert: e.message }.to_query
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

class Admin < Sinatra::Base

  use Rack::Auth::Basic do |u, p|
    u == 'geocode' && p == 'free'
  end

  get '/applications' do
    @applications = Application.all
    haml :'applications/index'
  end

end
