module Admin::CampaignsHelper
  def button_to_edit_campaign(item)
    link_to(content_tag(:span, '', class: 'glyphicon glyphicon-pencil'), edit_admin_campaign_path(item), class: 'btn btn-primary btn-xs btn-action')
  end

  def button_to_delete_campaign(item)
    link_to(content_tag(:span, '', class: 'glyphicon glyphicon-trash'), [:admin, item], method: :delete, data: { confirm: "Are you sure?"}, class: 'btn btn-danger btn-xs btn-action')
  end
end
