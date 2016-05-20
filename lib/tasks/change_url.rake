namespace :change_url do
  task production: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Blog.first.update(base_url: 'https://moneyadviceservice.org.uk/blog')
  end

  task staging: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Blog.first.update(base_url: 'https://www.staging.dev.mas.local/blog')
  end
end
