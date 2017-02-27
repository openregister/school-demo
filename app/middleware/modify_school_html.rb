require 'nokogiri'
require 'openregister'

# Injects school register data into given school html page.
class ModifySchoolHtml
  def initialize html
    @html = html
  end

  def modify
    doc = Nokogiri::HTML @html
    remove_header_logo! doc
    beta_to_alpha! doc
    add_school_register_content! doc
    doc.to_s.sub('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">','').strip
  end

  private

  def remove_header_logo! doc
    if logo = doc.at('.header-logo')
      logo.remove
    end
  end

  def beta_to_alpha! doc
    if phase = doc.at('.phase-banner-beta')
      phase.attributes['class'].value = 'phase-banner-alpha'
      if tag = doc.at('.phase-tag')
        tag.inner_html = 'ALPHA'
      end
    end
  end

  def school_for doc
    if ref_dt = doc.search('dt').detect {|x| x.to_s[/Unique reference/]}
      code = ref_dt.next_element.text
      puts code
      OpenRegister.record 'school-eng', code, ENV['PHASE'].to_sym
    end
  end

  def fields_by_registry item
    fields = item._register_fields.select{|f| f.register.present?}
    by_register = fields.group_by(&:register)
    registers = by_register.keys.each_with_object({}) do |register_name, h|
      h[register_name] = OpenRegister.register register_name, item._base_url_or_phase
    end
    by_registry = fields.group_by {|f| registers[f.register].registry }
  end

  def add_school_register_content! doc
    if school = school_for(doc)
      puts school.to_yaml

      records = [school].push(*OpenRegisterHelper.record_fields_from_list([school]))

      by_registry = records.group_by do |record|
        record._register.registry
      end

      register_data_html = by_registry.keys.sort.map do |registry|
        records = by_registry[registry]
        registry_html(registry, records) if records.size > 0
      end

      if div = doc.at('#FeedbackFormContainer')
        div.inner_html =
          [ '<h2 class="heading-small">This page uses data from a number of different registers</h2>',
        '<details>', '<summary><span class="summary">Register data</span></summary>',
        '<div aria-expanded="false">', register_data_html, '</div>', '</details>', ].flatten.join("\n")
      end
    end
  end

  def registry_html registry, records
    [
      '<dl>',
      "<h3 class='heading-medium'>#{registry.titleize}</h3>",
      item_html(records),
      '</dl>'
    ]
  end

  def item_html records
    records.uniq {|r| r._curie}.map do |record|
      values = record._register.fields.each_with_object({}) {|f, h| h[f]= record.send(f.underscore)}.to_json

      [
      "<dt style='margin-top: 0.7em; margin-bottom: 0.4em'><a href='#{record._uri}' rel='external'>",
      record._curie,
      '</a></dt>',
      '<dd><span style="background: #efefef; display: block; font-size: 0.75em; padding: 0.75em; color: #222;">',
      values.gsub('"',"'").gsub("':'", "': '").gsub("','", "', '"),
      '</span></dd>'
      ]
    end
  end
end
