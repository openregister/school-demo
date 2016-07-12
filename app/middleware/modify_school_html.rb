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
      OpenRegister.record 'school', code, :discovery
    end
  end

  def add_school_register_content! doc
    if school = school_for(doc)
      if div = doc.at('#FeedbackFormContainer')
        div.inner_html = [
          '<h2 class="heading-small">This page uses data from a number of different registers</h2>',
          '<details>',
          '<summary><span class="summary">Register data</span></summary>',
          '<div aria-expanded="false">Ipsum lorem</div>',
          '</details>',
        ].join("\n")
      end
    end
  end
end