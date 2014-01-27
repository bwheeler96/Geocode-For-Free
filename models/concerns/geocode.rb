module Geocode

  def geocode(loc)
    return [] if loc.length < 8          # If we get less than 8 letters, we can't do anything with that.
    names = loc.split(',')
    state = get_state(names)

    query = { name: names }
    query.merge!({ state: state[0] }) unless state.blank?

    city = City.find_by(query)
    city = City.find_by(name: names) if city.nil?

    # Return if nil?
    if city.blank?
      puts "Oh no! We couldn't find a city for #{loc}"
      return []
    end

    # Finally, the city
    puts "Selected #{city.name} for #{loc}"
    return [city.latitude, city.longitude]
  end

  def batch_geocode(locs)
    geodata = []
    result = {}
    fails = 0
    locs.map! { |x| x.downcase }
    benchmark = Benchmark.measure do
      locations = locs.join(',').split(',').select { |x| x.length > 4 && !(us_states.map{ |y| y[1] && !(us_states.map { |y| y[0] }).include?(x) }).include?(x) }
      puts "Received locations #{locations}"
      #ActiveRecord::Base.logger = nil # Stifle the database output for speed.
      cities = City.where('lower(name) IN (?)', locations) # Eager load the only possible results
      puts "Preloaded #{cities.count} possible cities."
      locs.each do |r|
        names = r.split(', ')
        state = get_state(names)

        if canada?(names)
          puts 'Canada'
          city = cities.detect { |x| x.country == 'Canada' && names.include?(x.name.downcase) }
          unless city.nil?
            geodata << Location.build(lat: city.latitude, lon: city.longitude, original: r)
            next
          end
        end

        if state.nil?
          state = get_state(names.join(' ').split(' '))
          names = r
          us_states.each do |s|
            names.slice! " #{s[0]}"
          end
          names.strip!
          names = names.split(', ')
        end
        if !state.nil?
          city = cities.detect { |x| x.state == state[1] && names.include?(x.name.downcase) }  # Drill down to the appropriate state
        end

        if city.nil?
          if !state.nil?
            geodata << Location.build(lat: state[2], lon: state[3], original: r)
            next
          end
          city = cities.select { |x| names.include? x.name.downcase }[0] # Hail Mary
        end

        # Return if nil?
        if city.blank?
          puts "OH NO! We couldn't find a city for #{r}"
          geodata << { failure: true, original: r }
          fails += 1
        else
          # Finally, the city
          #puts "CITY: #{city.name} for #{r.location}"
          #r.city = city
          geodata << Location.build(lat: city.latitude, lon: city.longitude, original: r)
        end
      end
    end
    result[:data] = geodata
    result[:meta] = {
      elapsed_time: benchmark.total,
      coverage: (locs.count.to_f - fails) / locs.count.to_f * 100
    }

    return result
  end

  def reverse_geocode(geocode)
    city = City.where(:latitude => (geocode[0]-0.5)..(geocode[0]+0.5), :longitude => (geocode[1]-0.5)..(geocode[1]+0.5)).first
    return 'EXACT' if city.nil?
    return city.name
  end

  def get_state(words)
    state = Object.new
    words.each do |w|
      state = us_states.detect { |x| x[0].downcase == w.downcase.strip || x[1].downcase == w.downcase.strip }
      break unless state.nil?
    end
    puts "Got state #{state} from #{words}."
    return state
  end

  def canada?(loc)
    loc.each do |l|
      return true if l.downcase.strip == 'canada'
    end
    return false
  end

  def us_states
    [["Alabama", "AL", "32.7990", "-86.8073"], ["Alaska", "AK", "61.3850", "-152.2683"], ["Arizona", "AZ", "33.7712", "-111.3877"], ["Arkansas", "AR", "34.9513", "-92.3809"], ["California", "CA", "36.1700", "-119.7462"], ["Colorado", "CO", "39.0646", "-105.3272"], ["Connecticut", "CT", "41.5834", "-72.7622"], ["Delaware", "DE", "39.3498", "-75.5148"], ["District of Columbia", "DC", "38.8964", "-77.0262"], ["Florida", "FL", "27.8333", "-81.7170"], ["Georgia", "GA", "32.9866", "-83.6487"], ["Hawaii", "HI", "21.1098", "-157.5311"], ["Idaho", "ID", "44.2394", "-114.5103"], ["Illinois", "IL", "40.3363", "-89.0022"], ["Indiana", "IN", "39.8647", "-86.2604"], ["Iowa", "IA", "42.0046", "-93.2140"], ["Kansas", "KS", "38.5111", "-96.8005"], ["Kentucky", "KY", "37.6690", "-84.6514"], ["Louisiana", "LA", "31.1801", "-91.8749"], ["Maine", "ME", "44.6074", "-69.3977"], ["Maryland", "MD", "39.0724", "-76.7902"], ["Massachusetts", "MA", "42.2373", "-71.5314"], ["Michigan", "MI", "43.3504", "-84.5603"], ["Minnesota", "MN", "45.7326", "-93.9196"], ["Mississippi", "MS", "32.7673", "-89.6812"], ["Missouri", "MO", "38.4623", "-92.3020"], ["Montana", "MT", "46.9048", "-110.3261"], ["Nebraska", "NE", "41.1289", "-98.2883"], ["Nevada", "NV", "38.4199", "-117.1219"], ["New Hampshire", "NH", "43.4108", "-71.5653"], ["New Jersey", "NJ", "40.3140", "-74.5089"], ["New Mexico", "NM", "34.8375", "-106.2371"], ["New York", "NY", "42.1497", "-74.9384"], ["North Carolina", "NC", "35.6411", "-79.8431"], ["North Dakota", "ND", "47.5362", "-99.7930"], ["Ohio", "OH", "40.3736", "-82.7755"], ["Oklahoma", "OK", "35.5376", "-96.9247"], ["Oregon", "OR", "44.5672", "-122.1269"], ["Pennsylvania", "PA", "40.5773", "-77.2640"], ["Puerto Rico", "PR", "18.2766", "-66.3350"], ["Rhode Island", "RI", "41.6772", "-71.5101"], ["South Carolina", "SC", "33.8191", "-80.9066"], ["South Dakota", "SD", "44.2853", "-99.4632"], ["Tennessee", "TN", "35.7449", "-86.7489"], ["Texas", "TX", "31.1060", "-97.6475"], ["Utah", "UT", "40.1135", "-111.8535"], ["Vermont", "VT", "44.0407", "-72.7093"], ["Virginia", "VA", "37.7680", "-78.2057"], ["Washington", "WA", "47.3917", "-121.5708"], ["West Virginia", "WV", "38.4680", "-80.9696"], ["Wisconsin", "WI", "44.2563", "-89.6385"], ["Wyoming", "WY", "42.7475", "-107.2085"]]
  end

  class Location

    attr_accessor :lat, :lon, :original

    def self.build(attributes={})
      l = self.new
      return l if attributes.empty?
      attributes.each do |k, v|
        l.send("#{k}=", v)
      end
      return l
    end

  end

end