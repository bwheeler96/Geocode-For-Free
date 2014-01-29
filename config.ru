require './geocode_for_free'

if GeocodeForFree.development?
  Pony.options = {
      :via => LetterOpener::DeliveryMethod,
      :via_options => { :location => File.expand_path('../tmp/letter_opener', __FILE__) }
  }
else
	Pony.options = {
  	:via => :smtp,
  	:via_options => {
	#    :address        => 'smtp.yourserver.com',
    	:port           => '25',
	#    :user_name      => 'user',
	#    :password       => 'password',
    	:authentication => :plain # :plain, :login, :cram_md5, no auth by default
	#    :domain         => "localhost.localdomain" # the HELO domain provided by the client to the server
  	}
	}
end

use GeocodeForFree
run Admin
