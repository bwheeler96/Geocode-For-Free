# This is GeocodeForFree

# Explicit requires
require 'rubygems'
require 'bundler'

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
    content_type :json
    if application_signed_in?
      if current_application.confirmed?
        georaw = Array(params[:locations])
        @geodata = batch_geocode(georaw)
        @geodata.to_json
      else
        { error: 'Please confirm your email to begin using Geocode For Free.' }.to_json
      end
    else
      { error: 'You need to include a valid api_key in each request' }.to_json
    end
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

  private

  def application_signed_in?
    return !!current_application
  end

  def current_application
    return Application.find_by_api_key(params[:api_key])
  end

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
