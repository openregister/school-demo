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

  def record_url item
    "https://#{item.register}.#{ENV['PHASE']}.openregister.org/record/#{item.record}"
  end

  def school_authority school
    authority = school.try(:_school_authority)
    authority.try(:_organisation).try(:name) || authority.try(:name)
  end

  def school_phase school
    if school.school_phase.present?
      school._school_phase.try(:name)
    else
      "Not applicable"
    end
  end

end
