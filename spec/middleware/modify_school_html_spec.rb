require 'spec_helper'
require_relative '../../app/middleware/modify_school_html'

RSpec.describe ModifySchoolHtml do

  describe 'modify' do
    it 'returns html' do
      html = '<html></html>'
      modifier = ModifySchoolHtml.new(html)
      expect(modifier.modify).to eq(html)
    end

    it 'removes header-logo' do
      html = '<html><body><div class="header-logo"></div></body></html>'
      modifier = ModifySchoolHtml.new(html)

      expected = '<html><body></body></html>'
      expect(modifier.modify).to eq(expected)
    end

    it 'removes changes beta phase tag to alpha' do
      html = '<html><body><div class="phase-banner-beta"><strong class="phase-tag">BETA</strong></div></body></html>'
      modifier = ModifySchoolHtml.new(html)

      expected = '<html><body><div class="phase-banner-alpha"><strong class="phase-tag">ALPHA</strong></div></body></html>'
      expect(modifier.modify).to eq(expected)
    end

    it 'adds school register content when school id present' do
      html = ['<html><body>',
      '<dl>',
      '<dt>Unique reference</dt>',
      '<dd>123</dd>',
      '</dl>',
      '<div id="FeedbackFormContainer"></div>',
      '</body></html>'].join("\n")
      expect(OpenRegister).to receive(:record).with('school', '123', :discovery).and_return double()
      modifier = ModifySchoolHtml.new(html)

      expected = ['<html><body>',
      '<dl>',
      '<dt>Unique reference</dt>',
      '<dd>123</dd>',
      '</dl>',
      '<div id="FeedbackFormContainer">',
      '<h2 class="heading-small">This page uses data from a number of different registers</h2>',
      '<details>',
      '<summary><span class="summary">Register data</span></summary>',
      '<div aria-expanded="false">Ipsum lorem</div>',
      '</details>',
      '</div>',
      '</body></html>'].join("\n")
      expect(modifier.modify).to eq(expected)
    end
  end

end
