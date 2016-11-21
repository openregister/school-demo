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
  def self.record_fields item
    item._register._fields.
      select{ |field| field.register.present? && field.register != item.class.register }.
      select{ |field| item.send(field.field.underscore).present? }.
      map do |field|
        value = item.send("_#{field.field.underscore}")
        puts ''
        puts '===='
        puts field.field
        puts item.send(field.field.underscore)
        puts value.class.name
        puts '---'
        puts ''
        value
    end
  end

  def self.record_fields_from_list items
    items.map do |item|
      if item.is_a?(Array)
        record_fields_from_list(item)
      elsif item.nil?
        nil
      else
        records = record_fields(item)
        records.push(*record_fields_from_list(records))
      end
    end.flatten.compact
  end

  def self.school id
    school = OpenRegister.record 'school-eng', id, ENV['PHASE'].to_sym
    set_address! school
    set_school_trust_organisation! school
    school
  end

  def self.set_address! school
    if school.address.present?
      school._address = OpenRegister.record 'address', school.address, :discovery
    else
      school._address = 'nil'
      school._address = nil
    end
  end

  def self.set_school_trust_organisation! school
    if school.school_trust.present?
      if school.school_trust.organisation.present?
        register, key = school.school_trust.organisation.split(':')
        school.school_trust._organisation = OpenRegister.record register, key, :discovery
      else
        school.school_trust._organisation = 'nil'
        school.school_trust._organisation = nil
      end
    end
  end
end
