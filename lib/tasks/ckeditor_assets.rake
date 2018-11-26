# frozen_string_literal: true

# From: https://www.rubydoc.info/gems/ckeditor/4.0.8#Usage_with_Rails_4_assets
namespace :ckeditor do
  desc 'Create nondigest versions of ckeditor assets'
  task :create_nondigest_assets do
    fingerprint = /\-[0-9a-f]{32}\./
    Dir['public/assets/ckeditor/**/*'].each do |file|
      next unless file =~ fingerprint
      nondigest = file.sub fingerprint, '.' # contents-0d8ffa186a00f5063461bc0ba0d96087.css => contents.css
      FileUtils.cp file, nondigest, verbose: true
    end
  end
end

Rake::Task['assets:precompile'].enhance do
  Rake::Task['ckeditor:create_nondigest_assets'].invoke
end
