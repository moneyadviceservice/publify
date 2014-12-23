class Admin::CampaignsController < ApplicationController
  layout 'administration'
  def index
    @campaigns = Campaign.all
  end

  def new
    @campaign = Campaign.new
  end
end
