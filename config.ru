require './geocode_for_free'

if GeocodeForFree.development?
  Pony.options = {
      :via => LetterOpener::DeliveryMethod,
      :via_options => { :location => File.expand_path('../tmp/letter_opener', __FILE__) }
  }
end

run GeocodeForFree
