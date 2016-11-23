require 'morph'
require 'openregister'

def add_value field, item, hash
  if value = item.try(field)
    hash[field] = value
  end
end

KEYS = {
  register: :r,
  phase: :h,
  record: :k,
  name: :n,
  place: :p,
  point: :coordinates,
  entry_number: :e,
  start_date: :s,
  end_date: :f,
}

def convert_keys hash
  hash.inject({}) {|memo,(k,v)| memo[KEYS[k]] = v; memo}
end

def values item, register
  hash = {
    register: register.to_s.gsub('_','-'),
    record: item.send(register)
  }
  [:name, :start_date, :end_date, :entry_number].each do |field|
    add_value field, item, hash
  end
  hash
end

def address_for item, addresses
  addresses[item.try(:address)].try(:first) if addresses
end

def street_for address, streets
  streets[address.try(:street)].try(:first)
end

def place_for street, places, local_authorities
  (places[street.try(:place)] || local_authorities[street.try(:street_custodian)]).try(:first)
end

def point_for item, addresses
  point = if point = item.try(:point)
            point
          elsif address = address_for(item, addresses)
            address.try(:point)
          end
  if point && point.size > 0
    eval(point)
  end
end

def place_for_school school, addresses, streets, places, local_authorities
  if address = address_for(school, addresses)
    if street = street_for(address, streets)
      place_for(street, places, local_authorities)
    end
  end
end

def items register
  puts "read: #{register}"
  tmp_dir = './tmp/data'
  tsv = IO.read "#{tmp_dir}/#{register}/#{register}.tsv" ; nil
  items = Morph.from_tsv tsv, register
end

def osplaces
  puts 'read: osplaces'
  tmp_dir = './tmp/data'
  tsv = IO.read "#{tmp_dir}/os-open-names/places.tsv"
  items = Morph.from_tsv tsv, 'OSPlace'
end

def phase_for register
  name = register.to_s.gsub('_','-')
  if Rails.configuration.alpha_registers.include?(name)
    :alpha
  elsif Rails.configuration.discovery_registers.include?(name)
    :discovery
  else
    raise "unknown phase for: #{register}"
  end  
end

def create_item_hash item, register, place, addresses
  hash = values(item, register)
  point = point_for(item, addresses)
  hash[:point] = point if point
  hash[:place] = place if place
  hash[:phase] = phase_for(register)
  convert_keys hash
end

def county_for place, osplaces
  if (osplace = osplaces[place.point]) && county = osplace.first.try(:county)
    county
  else
    raise place.inspect
    place.uk
  end
end

schools = items 'school-eng' ; nil
addresses = items('address').group_by(&:address) ; nil
streets = items('street').group_by(&:street) ; nil
places = items('place').group_by(&:place) ; nil
osplaces = osplaces().group_by(&:point) ; nil
local_authorities = items('local-authority-eng').group_by(&:local_authority_eng) ; nil

puts 'delete items collection'
Item.delete_all
puts 'remove indexes'
puts `rake db:mongoid:remove_indexes`

puts 'persist school names'
list = schools.map do |school|
  place = place_for_school(school, addresses, streets, places, local_authorities).try(:name)
  create_item_hash school, :school_eng, place, addresses
end ; nil
result = Item.collection.insert_many(list, ordered: false) ; nil

=begin
puts 'persist street names'
list = streets.values.map do |street|
  street = street.first
  place = place_for(street, places, local_authorities).try(:name)
  create_item_hash street, :street, place, addresses
end ; nil
result = Item.collection.insert_many(list, ordered: false) ; nil
=end

puts 'persist place names'
list = places.values.map do |place|
  place = place.first
  county = county_for(place, osplaces)
  create_item_hash place, :place, county, nil
end ; nil
result = Item.collection.insert_many(list, ordered: false) ; nil

puts 'create indexes'
puts `rake db:mongoid:create_indexes`
