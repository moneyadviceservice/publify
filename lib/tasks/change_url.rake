namespace :change_blog_base_url do
  desc 'Change Blog base_url pointing to blog production url'
  task production: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Blog.first.update(base_url: 'https://moneyadviceservice.org.uk/blog')
  end

  desc 'Change Blog base_url pointing to blog staging url'
  task staging: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Blog.first.update(base_url: 'https://www.staging.dev.mas.local/blog')
  end
end
