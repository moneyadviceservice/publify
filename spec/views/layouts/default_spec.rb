require 'rails_helper'

describe 'layouts/default.html.erb', type: :view do
  before(:each) do
    assign(:keywords, %w(foo bar))
    assign(:auto_discovery_url_atom, '')
    assign(:auto_discovery_url_rss, '')
  end

  it 'has keyword meta tag when use_meta_keyword set to true' do
    create(:blog, use_meta_keyword: true)
    render
    expect(rendered).to have_selector('head>meta[name="keywords"]', visible: false)
  end

  it 'does not have keyword meta tag when use_meta_keyword set to false' do
    create(:blog, use_meta_keyword: false)
    render
    expect(rendered).to_not have_selector('head>meta[name="keywords"]', visible: false)
  end
end
