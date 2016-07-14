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
      OpenRegister.record 'school', code, :discovery
    end
  end

  def add_school_register_content! doc
    if school = school_for(doc)
      puts school.to_yaml
      register = school.class._register(:discovery)
      fields = register._fields.select{|f| f.register.present?}
      by_register = fields.group_by(&:register)
      by_register.delete('')
      registers = by_register.keys.each_with_object({}) { |r, h| h[r] = OpenRegister.register r, :discovery }
      by_registry = fields.group_by {|f| registers[f.register].registry }
      register_data_html = by_registry.keys.map{|r| registry_html r, by_registry[r], school}
      # byebug
      if div = doc.at('#FeedbackFormContainer')
        div.inner_html =
          [ '<h2 class="heading-small">This page uses data from a number of different registers</h2>',
        '<details>', '<summary><span class="summary">Register data</span></summary>',
        '<div aria-expanded="false">', register_data_html, '</div>', '</details>', ].flatten.join("\n")
      end
    end
  end

  def registry_html registry, fields, item
    [
      '<dl>',
      "<h3 class='heading-medium'>#{registry.titleize}</h3>",
      item_html(fields, item),
      '</dl>'
    ]
  end

  require 'json'
  def item_html fields, item
    fields.map do |field|
      begin
      puts field.field
      field_label = item.send(field.field.underscore)
      puts field_label.to_yaml
      if field_label.blank?
        []
      else
        field_label = field_label.first if field_label.is_a?(Array)
        field_value = item.send("_#{field.field.underscore}")
        field_value = field_value.first if field_value.is_a?(Array)
        values = field_value.class._register(:discovery).fields.each_with_object({}) {|f, h| h[f]= field_value.send(f.underscore)}.to_json
        [
        "<dt style='margin-top: 0.7em; margin-bottom: 0.4em'><a href='#{item._uri}' rel='external'>",
        "#{field.register}:#{field_label}",
        '</a></dt>',
        '<dd><span style="background: #efefef; display: block; font-size: 0.75em; padding: 0.75em; color: #222;">',
        values.gsub('"',"'").gsub("':'", "': '").gsub("','", "', '"),
        '</span></dd>'
        ]
      end
      rescue Exception => e
        puts e.to_s
      []
    end
    end
  end
end