feature 'Campaigns' do
  let(:campaigns_page)     { CampaignsPage.new }
  let(:new_campaigns_page) { NewCampaignsPage.new }
  let!(:fake_campaign)     { create(:campaign, title: 'Save money at the supermarket', active: true, primary_link: create(:campaign_link), secondary_link: create(:campaign_link, link_type: 'blog')) }

  background do
    create(:blog)
    sign_in(:as_admin)
    campaigns_page.load
  end

  scenario 'as an admin, i am able to view campaigns' do
    when_i_view_the_campaigns_page
    i_can_see_all_campaigns
  end

  scenario 'an an admin, i am able to create a campaign' do
    when_i_view_the_new_campaigns_page
    and_i_create_a_new_campaign
    then_i_see_a_successful_confirmation
  end

  def when_i_view_the_campaigns_page
    expect(campaigns_page).to be_displayed
  end

  def i_can_see_all_campaigns
    expect(page).to have_selector('a', text: fake_campaign.title)
  end

  def when_i_view_the_new_campaigns_page
    new_campaigns_page.load
    expect(new_campaigns_page).to be_displayed
  end

  def and_i_create_a_new_campaign
    new_campaigns_page.title.set 'Save money at the supermarket'
    new_campaigns_page.description.set 'Going to university is all about having a good time, discovering yourself and making new friends, right?'
    new_campaigns_page.active.set(true)
    new_campaigns_page.primary_link_type.select 'Ma Says'
    new_campaigns_page.primary_link_title.set 'Smart shopping: simple tips and tricks to save you money'
    new_campaigns_page.primary_link_url.set 'http//www.example.com'
    new_campaigns_page.secondary_link_type.select 'Blog'
    new_campaigns_page.secondary_link_title.set 'Save money in your shopping basket every week and if this title was longer it'
    new_campaigns_page.secondary_link_url.set 'http//www.example.com'
    new_campaigns_page.submit.click
  end

  def then_i_see_a_successful_confirmation
    expect(page).to have_content('Campaign created successfully')
  end

end
