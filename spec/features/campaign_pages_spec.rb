feature 'Campaigns' do
  let(:campaigns_page)        { CampaignsPage.new }
  let(:fake_campaign)         { create(:campaign, title: 'Save money at the supermarket') }
  let(:second_fake_campaign)  { create(:campaign, title: 'Only fools and horses') }

  background do
    create(:blog)
    sign_in(:as_admin)
    campaigns_page.load
  end

  scenario 'Viewing all campaigns' do
    when_i_view_the_campaigns_page_as_an_admin
    i_can_see_all_campaigns
  end

  def when_i_view_the_campaigns_page_as_an_admin
    expect(campaigns_page).to be_displayed
  end

  def i_can_see_all_campaigns
    expect(page).to have_content(fake_campaign.title)
    expect(page).to have_content(second_fake_campaign.title)
  end

end
