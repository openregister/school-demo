class Item

  include Mongoid::Document
  include Mongoid::Timestamps

  field :r, as: :register, type: String
  field :k, as: :record, type: String
  field :n, as: :name, type: String
  field :p, as: :place, type: String
  field :e, as: :entry_number, type: Integer
  field :s, as: :start_date, type: Date
  field :f, as: :end_date, type: Date

  field :coordinates, type: Array

  validates_uniqueness_of :record, scope: :register

  attr_readonly :register, :record

  scope :not_ended, -> { where(end_date: nil) }

  scope :with_coordinates, -> { where(:coordinates.ne => nil) }

  scope :at, -> (point) { where(coordinates: lon_lat(point)) }
  scope :not_street, -> { where(:register.ne => 'street') }

  scope :schools, -> { where(register: 'school') }
  scope :places, -> { where(register: 'place') }

  scope :matching, -> (pattern, limit) { where(name: pattern).not_street.not_ended.with_coordinates.limit(limit) }

  index({ register: 1 }, unique: false)
  index({ register: 1, record: 1 }, unique: true)
  index({ name: 1 }, unique: false)
  index({ coordinates: "2dsphere"})

  class << self
    def search_pattern query
      pattern = query.to_s.strip.gsub(/\s+/,' ')
      # postcode = UKPostcode.parse(pattern)
      # if postcode.valid?
        # postcode.outcode
      # else
        pattern
      # end
    end

    def matches_for query, limit
      pattern = search_pattern(query)
      matches = matching(pattern, limit) +
        matching(/^#{pattern}/i, limit)
        # matching(/^(.+\s)+#{pattern}/i)
      matches.uniq
    end

    def search query, limit: 5
      query.blank? ? [] : matches_for(query, limit)
    end

    def record register, record
      begin
        find_by(register: register, record: record)
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end
    end

    def nearest_schools point
      schools.geo_near(lon_lat(point)).spherical
    end

    def school_at point
      schools_at_point = schools.at(point)
      schools_at_point.not_ended.first || schools_at_point.first
    end

    def lon_lat point
      if point.is_a?(String)
        lon, lat = point.split(',')
        lon = clean_coord lon
        lat = clean_coord lat
        [lon, lat]
      else
        point
      end
    end

    def clean_coord coord
      BigDecimal.new(coord.to_s).to_f
    end
  end

  def curie
    [register, record].join(':')
  end

  def display_place
    case place
    when 'ENG'
      'England'
    when 'WLS'
      'Wales'
    when 'SCT'
      'Scotland'
    when 'NIR'
      'Northern Ireland'
    else
      place
    end
  end

  def display_name
    [name.titleize, display_place].compact.join(', ')
  end

  def as_json(opts=nil)
    {
      curie: curie,
      name: display_name,
      point: coordinates
    }
  end

end
