class RemoveHeroImageAltTextFromCampaigns < ActiveRecord::Migration
  def change
    remove_column :campaigns, :hero_image_alt_text
  end
end
