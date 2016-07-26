module OpenRegister
  class << self
    alias_method :original_record, :record

    def record register, record, base_url_or_phase=nil
      key = [register, record, base_url_or_phase].join(' | ')
      if Rails.cache.read(key).present?
        puts 'from cache ' + key
        Rails.cache.read(key)
      else
        puts 'retrieving ' + key
        result = original_record register, record, base_url_or_phase
        Rails.cache.write(key, result)
        result
      end
    end
  end
end

module OpenRegisterHelper
  def self.record_fields item
    item._register._fields.
      select{ |field| field.register.present? && field.register != item.class.register }.
      select{ |field| item.send(field.field.underscore).present? }.
      map do |field|
      puts ''
      puts '===='
      puts field.field
      puts item.send(field.field.underscore)
      puts '---'
      puts ''
      item.send("_#{field.field.underscore}")
    end
  end

  def self.record_fields_from_list items
    items.map do |item|
      if item.is_a?(Array)
        record_fields_from_list(item)
      else
        records = record_fields(item)
        records.push(*record_fields_from_list(records))
      end
    end.flatten
  end

end
