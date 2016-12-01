module ApplicationHelper

  def display_address address
    street = address.try(:_street)
    parent_address = address.try(:parent_address).present? ? address.try(:_parent_address) : nil
    address_lines = [address, parent_address, street].
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

  def religious_characters school, religion_field
    if school.send(religion_field).present?
      school.send(:"_#{religion_field}").map(&:name).join(", ")
    else
      'Does not apply'
    end
  end

  def record_url item
    "https://#{item.register}.#{item.phase}.openregister.org/record/#{item.record}"
  end

  def school_authority school
    authority = school.try(:_school_authority_eng)
    authority.try(:_organisation).try(:name) || authority.try(:name)
  end

  def school_type school
    case school._organisation.class.name
    when 'NilClass'
      ""
    when 'OpenRegister::SchoolType'
      school._organisation.name
    else
      school._organisation._school_type.name
    end
  end

  def school_phase school
    if school.school_phases.present?
      school._school_phases.map{|p| p.try(:name)}.join(', ')
    else
      "Not applicable"
    end
  end

  def headteacher school
    if school.try(:headteacher).present?
      school.headteacher
    elsif school.try(:end_date).present?
      ''
    else
      'Not yet notified'
    end
  end

  def trust_name company
    if company.present?
      company.name
    else
      ""
    end
  end

  def previous_trust_names company
    if company.present? && company._versions.size > 1
      lines = company._version_change_display(:name, :start_date, :name_change_date)
      '<p class="previous-names">'+
      'previous trust ' + 'name'.pluralize(lines.size) + ': <br />' +
      lines.join('<br />') +
      '</p>'
    end
  end

  def date date
    if date.present?
      Date.parse(date).strftime('%e %B %Y')
    end
  end
end
