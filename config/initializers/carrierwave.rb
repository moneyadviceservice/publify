if Rails.env.in?(%(development test cucumber))
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
else
  CarrierWave.configure do |config|
    require 'azure/blob/blob_service'
    config.storage = :azure
    config.azure_storage_account_name = ENV['AZURE_ASSETS_STORAGE_BLOG_ACCOUNT_NAME']
    config.azure_storage_access_key = ENV['AZURE_ASSETS_STORAGE_BLOG_ACCOUNT_KEY']
    config.azure_container = ENV['AZURE_ASSETS_STORAGE_BLOG_CONTAINER']
    config.asset_host = ENV['AZURE_ASSETS_STORAGE_BLOG_URL']
  end
end
