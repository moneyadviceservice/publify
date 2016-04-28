feature 'Sharing buttons' do
  background do
    create(:blog)
  end

  scenario 'when user visit the styleguide' do
    visit styleguide_show_path

    contains_sharing_bar
  end

  scenario 'when user visit the styleguide article page' do
    visit styleguide_article_page_path

    contains_sharing_bar
  end

  def contains_sharing_bar
    # This is hard coded into the styleguide
    expected_shared_url = 'http%3A%2F%2Fwww.moneyadviceservice.org.uk%2Fblog%2Fsome-article'

    expect(page).to have_css('.t-sharing')
    expect(page).to have_css('.t-facebook-button')
    expect(page).to have_css('.t-twitter-button')
    expect(page.find('a.t-pinterest-button')['href']).to include(expected_shared_url)
    expect(page.find('a.t-google-button')['href']).to include(expected_shared_url)
    expect(page).to have_css('.t-print-button')
    expect(page).to have_css('.t-email-button')
  end
end
