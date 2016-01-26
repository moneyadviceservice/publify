# coding: utf-8

# Factory definitions
FactoryGirl.define do

  sequence :name do |n|; "name_#{n}"; end
  sequence :body do |n|; "body #{n}" * (n + 3 % 5); end
  sequence :user do |n|; "user#{n}"; end
  sequence :email do |n|; "user#{n}@example.com"; end
  sequence :guid do |n|; "deadbeef#{n}"; end
  sequence :label do |n|; "lab_#{n}"; end
  sequence :file_name do |f|; "file_name_#{f}"; end
  sequence :time do |n|; DateTime.new(2012, 3, 26, 19, 56) - n; end

  factory :user do
    login { FactoryGirl.generate(:user) }
    email { generate(:email) }
    name 'Bond'
    nickname 'James Bond'
    notify_via_email false
    notify_on_new_articles false
    notify_on_comments false
    password 'top-secret'
    state 'active'
    twitter '@getpublify'
    association :profile, factory: :profile
    association :resource, factory: :avatar
    association :text_filter, factory: :textile

    trait :without_twitter do
      twitter nil
      association :resource, nil
    end

    trait :with_a_full_profile do
      description 'I am a poor lonesone factory generated user'
      url 'http://myblog.net'
      msn 'random@mail.com'
      aim 'randomaccount'
      yahoo 'anotherrandomaccount'
      twitter '@random'
      jabber 'random@account.com'
    end

    trait :with_twitter do
      twitter_oauth_token 'oauth_token'
      twitter_oauth_token_secret 'oauth_token'
    end

    trait :as_admin do
      association :profile, factory: :profile_admin
    end

    trait :as_publisher do
      association :profile, factory: :profile_publisher
    end

  end

  factory :article do
    title 'A big article'
    body 'A content with several data'
    extended 'extended content for fun'
    guid
    sequence(:permalink) { |n| "a-big-article-#{n}" }
    published_at DateTime.new(2005, 1, 1, 2, 0, 0)
    user
    tags []
    published_comments []
    published_trackbacks []
    allow_comments true
    published true
    state :published
    allow_pings true
    association :text_filter, factory: :textile

    trait :with_tags do
      keywords 'a tag'
    end
  end

  factory :unpublished_article, parent: :article do |a|
    a.published_at nil
    a.published false
  end

  factory :content do
    sequence(:permalink) { |n| "some-content-#{n}" }
  end

  factory :post_type do |p|
    p.name 'foobar'
    p.description 'Some description'
  end

  factory :markdown, class: :text_filter do
    name 'markdown'
    description 'Markdown'
    markup 'markdown'
    filters '--- []'
    params '--- {}'

    after :stub do |filter|
      TextFilter.stub(:find_by_name).with(filter.name) { filter }
    end
  end

  factory :smartypants, parent: :markdown do |m|
    m.name 'smartypants'
    m.description 'SmartyPants'
    m.markup 'none'
    m.filters %q{ [:smartypants].to_yaml.inspect }
  end

  factory 'markdown smartypants', parent: :smartypants do |m|
    m.name 'markdown smartypants'
    m.description 'Markdown with SmartyPants'
    m.markup 'markdown'
    m.filters [:smartypants]
  end

  factory :textile, parent: :markdown do |m|
    m.name 'textile'
    m.description 'Textile'
    m.markup 'textile'
  end

  factory :none, parent: :markdown do |_m|
    name 'none'
    description 'None'
    markup 'none'

    after :stub do |_filter|
      TextFilter.stub(:find_by_name).with('') { nil }
    end
  end

  factory :utf8article, parent: :article do |u|
    u.title 'ルビー'
    u.sequence(:permalink) { |n| "ルビー#{n}" }
  end

  factory :second_article, parent: :article do |a|
    a.title 'Another big article'
  end

  factory :article_with_accent_in_html, parent: :article do |a|
    a.title 'article with accent'
    a.body '&eacute;coute The future is cool!'
    a.sequence(:permalink) { |n| "article-with-accent-#{n}" }
  end

  factory :blog do
    base_url 'http://myblog.net'
    hide_extended_on_rss true
    blog_name 'test blog'
    limit_article_display 2
    sp_url_limit 3
    plugin_avatar ''
    blog_subtitle 'test subtitles'
    limit_rss_display 10
    ping_urls "http://ping.example.com/ping
http://alsoping.example.com/rpc/ping"
    geourl_location ''
    default_allow_pings false
    send_outbound_pings false
    sp_global true
    default_allow_comments true
    email_from 'scott@sigkill.org'
    association :text_filter, factory: :textile
    sp_article_auto_close 0
    link_to_author false
    association :comment_text_filter, factory: :markdown
    use_canonical_url true
    lang 'en_US'

    after :stub do |blog|
      Blog.stub(:default) { blog }
      [blog.text_filter, blog.comment_text_filter].uniq.each do |filter|
        build_stubbed filter
      end
    end

    factory :blog_with_twitter do
      twitter_consumer_key 'consumer_key'
      twitter_consumer_secret 'consumer_secret'
    end
  end

  factory :profile, class: :profile do
    label { FactoryGirl.generate(:label) }
    nicename 'Publify contributor'
    modules [:dashboard, :profile]

    factory :profile_admin do
      label Profile::ADMIN
      nicename 'Publify administrator'
      modules [ :dashboard, :write, :articles, :pages, :feedback, :customizesidebar, :users, :seo, :media, :settings, :profile, :notes ]
    end

    factory :profile_publisher do
      label 'publisher'
      nicename 'Blog publisher'
      modules [:users, :dashboard, :write, :articles, :pages, :feedback, :media, :notes]
    end

    factory :profile_contributor do
    end
  end

  factory :tag do |tag|
    tag.name { FactoryGirl.generate(:name) }
    tag.display_name { |a| a.name }
  end

  factory :resource do |r|
    r.upload { FactoryGirl.generate(:file_name) }
    r.mime 'image/jpeg'
    r.size 110
  end

  factory :avatar, parent: :resource do |a|
    a.upload 'avatar.jpg'
    a.mime 'image.jpeg'
    a.size 600
  end

  factory :redirect do |r|
    r.from_path 'foo/bar'
    r.to_path '/someplace/else'
  end

  factory :comment do
    published true
    article
    association :text_filter, factory: :textile
    author 'Bob Foo'
    url 'http://fakeurl.com'
    email 'bob@foo.com'
    body 'Test <a href="http://fakeurl.co.uk">body</a>'
    created_at '2005-01-01 02:00:00'
    updated_at '2005-01-01 02:00:00'
    published_at '2005-01-01 02:00:00'
    guid
    state 'ham'

    factory :unconfirmed_comment do |c|
      c.state 'presumed_ham'
      c.status_confirmed false
      c.published false
    end

    factory :published_comment do |c|
      c.state 'ham'
      c.status_confirmed true
      c.published true
    end

    factory :not_published_comment do |c|
      c.state 'spam'
      c.status_confirmed true
      c.published false
    end

    factory :ham_comment do |c|
      c.state 'ham'
      c.published false
    end

    factory :presumed_ham_comment do |c|
      c.state 'presumed_ham'
      c.published false
    end

    factory :presumed_spam_comment do |c|
      c.state 'presumed_spam'
      c.published false
    end

    factory :spam_comment do |c|
      c.state 'spam'
      c.published false
    end
  end

  factory :page do
    name { FactoryGirl.generate(:name) }
    title 'Page One Title'
    body { FactoryGirl.generate(:body) }
    sequence(:permalink) { |n| "a-page-#{n}" }
    created_at '2005-05-05 01:00:01'
    published_at '2005-05-05 01:00:01'
    updated_at '2005-05-05 01:00:01'
    user
    published true
    state 'published'
  end

  factory :note do
    body 'this is a note'
    created_at '2013-07-14 01:00:01'
    published_at '2013-07-14 01:00:01'
    updated_at '2013-07-14 01:00:01'
    user
    published true
    state 'published'
    association :text_filter, factory: :markdown
    guid
  end

  factory :unpublished_note, parent: :note do |n|
    n.published false
  end

  factory :trackback do |_t|
    published true
    state 'ham'
    article
    status_confirmed true
    blog_name 'Trackback Blog'
    title 'Trackback Entry'
    url 'http://www.example.com'
    excerpt 'This is an excerpt'
    guid 'dsafsadffsdsf'
    created_at Time.now
    updated_at Time.now
  end
end

FactoryGirl.define do
  factory :campaign do
    title 'Save money at the supermarket'
    description 'Going to university is all about having a good time, discovering yourself and making new friends, right? Well, yes but hopefully you will learn a lot and get a good qualification as well.'
    hero_image Rack::Test::UploadedFile.new((File.join(Rails.root, 'app', 'assets', 'images', 'campaigns-hero-placeholder.png')))
    hero_image_alt_text 'alt text'
    active false
  end

  factory :campaign_link  do
    title 'Smart shopping: simple tips and tricks to save you money'
    url 'http//www.example.com'
    link_type 'ma_says'
    campaign
  end
end
