require 'morph'
require 'openregister'

def add_value field, item, hash
  if value = item.try(field)
    hash[field] = value
  end
end

KEYS = {
  register: :r,
  record: :k,
  name: :n,
  place: :p,
  point: :g,
  entry_number: :e,
  start_date: :s,
  end_date: :f,
}

def convert_keys hash
  hash.inject({}) {|memo,(k,v)| memo[KEYS[k]] = v; memo}
end

def values item, register
  hash = {
    register: register,
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

def place_for street, places
  places[street.try(:place)].try(:first)
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

def place_for_school school, addresses, streets, places
  if address = address_for(school, addresses)
    if street = street_for(address, streets)
      place_for(street, places)
    end
  end
end

def items register
  tsv = IO.read "../discovery/data/#{register}/#{register}.tsv" ; nil
  items = Morph.from_tsv tsv, register
end

def create_item_hash item, register, place, addresses
  hash = values(item, register)
  point = point_for(item, addresses)
  hash[:point] = point if point
  hash[:place] = place if place
  convert_keys hash
  # item = Item.find_or_create_by(register: register, record: record)
  # item.name = name
  # item.start_date = start_date
  # item.end_date = end_date
  # item.point = point if point
  # item.place = place if place
  # print '.'
  # item.save!
end

schools = items 'school' ; nil
addresses = items('address').group_by(&:address) ; nil
streets = items('street').group_by(&:street) ; nil
places = items('place').group_by(&:place) ; nil
local_authorities = items('local-authority').group_by(&:local_authority) ; nil

Item.delete_all

list = schools.map do |school|
  place = place_for_school(school, addresses, streets, places).try(:name)
  print '.'
  create_item_hash school, :school, place, addresses
end ; nil

result = Item.collection.insert_many(list, ordered: false) ; nil

list = streets.values.map do |street|
  street = street.first
  place = place_for(street, places).try(:name)
  print ','
  create_item_hash street, :street, place, addresses
end ; nil

result = Item.collection.insert_many(list, ordered: false) ; nil

list = places.values.map do |place|
  place = place.first
  print '`'
  create_item_hash place, :place, place.uk, nil
end ; nil

result = Item.collection.insert_many(list, ordered: false) ; nil
