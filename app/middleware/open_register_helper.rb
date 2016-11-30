# module OpenRegister
  # class << self
    # alias_method :original_record, :record
#
    # def record register, record, base_url_or_phase=nil
      # key = [register, record, base_url_or_phase].join(' | ')
      # if Rails.cache.read(key).present?
        # puts 'from cache ' + key
        # Rails.cache.read(key)
      # else
        # puts 'retrieving ' + key
        # result = original_record register, record, base_url_or_phase
        # Rails.cache.write(key, result)
        # result
      # end
    # end
  # end
# end

module OpenRegisterHelper

  def self.is_curie_link? field
    field.datatype == "curie"
  end

  def self.is_register_link? field, item_register
    (field.register.present? &&  item_register != field.register) ||
    (field.field == "address" && item_register != "address") ||
    (field.field == "academy-trust")
  end

  def self.is_record_link? field, item
    is_curie_link?(field) || is_register_link?(field, item.class.register)
  end

  def self.record_fields item
    item._register._fields.
      select{ |field| is_record_link?(field, item) }.
      select{ |field|
        begin
          item.send(field.field.underscore).present?
        rescue Exception => e
          puts e.to_s
          puts e.backtrace.join("\n")
          false
        end
      }.
      map do |field|
        value = item.send("_#{field.field.underscore}")
        puts "#{field.field}:#{item.send(field.field.underscore)} - #{value.class.name}"
        puts '==='
        value
    end
  end

  def self.record_fields_from_list items
    items.map do |item|
      if item.is_a?(Array)
        record_fields_from_list(item)
      elsif item.present?
        records = record_fields(item)
        records.push(*record_fields_from_list(records))
      end
    end.flatten.compact
  end

  def self.school id
    school = OpenRegister.record 'school-eng', id, ENV['PHASE'].to_sym
    set_address! school, :discovery
    case school._organisation.class.name
      when 'OpenRegister::AcademySchoolEng'
        set_academy_trust_company! school._organisation, :discovery
    end
    school
  end

  def self.set_address! school, phase
    if school.address.present?
      if school.try(:_address).blank?
        school._address = OpenRegister.record 'address', school.address, phase
      end
    else
      school._address = 'nil'
      school._address = nil
    end
  end

  def self.set_academy_trust_company! academy, phase
    if academy.present?
      if academy.academy_trust.present?
        if academy.try(:_academy_trust).blank?
          register, key = academy.academy_trust.split(':')
          academy._academy_trust = OpenRegister.record register, key, phase
        end
      else
        academy._academy_trust = 'nil'
        academy._academy_trust = nil
      end
    end
  end
end
