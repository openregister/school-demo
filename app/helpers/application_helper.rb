module ApplicationHelper

  def display_address address
    street = address.try(:_street)
    address_line = [address, street].compact.map(&:name).map(&:downcase).map(&:titlecase).join(' ')
    [
      address_line,
      street.try(:_place).try(:name),
      street.try(:_local_authority).try(:name),
    ].compact.join(', ')
  end

  def age_range school
    [school.minimum_age, school.maximum_age].join(' to ')
  end

  def denominations school
    if school.denominations.present?
      school._denominations.map(&:name).join(", ")
    end
  end

end
