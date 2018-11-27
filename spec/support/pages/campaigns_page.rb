class CampaignsPage < SitePrism::Page
  set_url '/blog/admin/campaigns'
  set_url_matcher(/campaigns/)

  element :delete, 'a.btn-danger'
end
