module ApplicationHelper

  def display_address address
    street = address.try(:_street)
    address_lines = [address, street].
                    compact.
                    map(&:name).
                    map(&:strip).
                    select(&:present?).
                    map(&:downcase).
                    map(&:titlecase)
    lines = address_lines + [
      street.try(:_place).try(:name)
    ]
    lines.
    compact.
    join('<br />').
    html_safe
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
