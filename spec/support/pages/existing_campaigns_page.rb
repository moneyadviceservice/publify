class ExistingCampaignsPage < SitePrism::Page
  set_url '/blog/admin/campaigns/{id}/edit'
  set_url_matcher(/campaigns/)

  element :campaign_title, '#campaign_title'

  element :submit, "input[value='Save']"


end
