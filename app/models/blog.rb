# The Blog class represents the one and only blog.  It stores most
# configuration settings and is linked to most of the assorted content
# classes via has_many.
#
# Once upon a time, there were plans to make publify handle multiple blogs,
# but it never happened and publify is now firmly single-blog.
#
class Blog < ActiveRecord::Base
  include ConfigManager
  include Rails.application.routes.url_helpers

  attr_accessor :custom_permalink

  default_scope -> { order('id') }

  validate(on: :create) { |blog|
    unless Blog.count.zero?
      blog.errors.add(:base, 'There can only be one...')
    end
  }

  validates :blog_name, presence: true

  serialize :settings, Hash

  # Description
  setting :blog_name,                  :string, 'My Shiny Weblog!'
  setting :blog_subtitle,              :string, ''
  setting :geourl_location,            :string, ''
  setting :canonical_server_url,       :string, ''  # Deprecated
  setting :lang,                       :string, 'en_US'
  setting :title_prefix,               :integer, 0 # Deprecated but needed for a migration

  # Spam
  setting :sp_global,                  :boolean, false
  setting :sp_article_auto_close,      :integer, 0
  setting :sp_url_limit,               :integer, 0
  setting :sp_akismet_key,             :string, ''
  setting :use_recaptcha,              :boolean, false

  # Mostly Behaviour
  setting :text_filter,                :string, 'markdown smartypants'
  setting :comment_text_filter,        :string, 'markdown smartypants'
  setting :limit_article_display,      :integer, 10
  setting :limit_rss_display,          :integer, 10
  setting :default_allow_pings,        :boolean, false
  setting :default_allow_comments,     :boolean, true
  setting :default_moderate_comments,  :boolean, false
  setting :link_to_author,             :boolean, false
  setting :show_extended_on_rss,       :boolean, true # deprecated but still needed for backward compatibility
  setting :hide_extended_on_rss,       :boolean, false
  setting :plugin_avatar,              :string, ''
  setting :global_pings_disable,       :boolean, false
  setting :ping_urls,                  :string, "http://blogsearch.google.com/ping/RPC2\nhttp://rpc.technorati.com/rpc/ping\nhttp://ping.blo.gs/\nhttp://rpc.weblogs.com/RPC2"
  setting :send_outbound_pings,        :boolean, true
  setting :email_from,                 :string, 'notmonitored@notify.moneyadviceservice.org.uk'
  setting :date_format,                :string, '%B %d %Y'
  setting :time_format,                :string, '%Hh%M'
  setting :image_avatar_size,          :integer, 48
  setting :image_thumb_size,           :integer, 150
  setting :image_medium_size,          :integer, 600

  # SEO
  setting :meta_description,           :string, ''
  setting :meta_keywords,              :string, ''
  setting :rss_description,            :boolean, false
  setting :rss_description_text,       :string, "<hr /><p><small>Original article written by %author% and published on <a href='%blog_url%'>%blog_name%</a> | <a href='%permalink_url%'>direct link to this article</a> | If you are reading this article anywhere other than on <a href='%blog_url%'>%blog_name%</a>, it has been illegally reproduced and without proper authorization.</small></p>"
  setting :robots,                     :string, 'User-agent: *\nAllow: /\nDisallow: /admin\n'
  
  setting :index_categories,           :boolean, true # deprecated but still needed for backward compatibility
  setting :unindex_categories,         :boolean, false
  setting :index_tags,                 :boolean, true # deprecated but still needed for backward compatibility
  setting :unindex_tags,               :boolean, false
  setting :admin_display_elements,     :integer, 10
  setting :google_verification,        :string, ''
  setting :nofollowify,                :boolean, true # deprecated but still needed for backward compatibility
  setting :dofollowify,                :boolean, false
  setting :use_canonical_url,          :boolean, false
  setting :use_meta_keyword,           :boolean, true
  setting :home_title_template,        :string, '%blog_name% | %blog_subtitle%' # spec OK
  setting :home_desc_template,         :string, '%blog_name% | %blog_subtitle% | %meta_keywords%' # OK
  setting :page_title_template,        :string, '%title% | %blog_name%'
  setting :page_desc_template,         :string, '%excerpt%'
  setting :paginated_title_template,   :string, '%blog_name% | %blog_subtitle% %page%'
  setting :paginated_desc_template,    :string, '%blog_name% | %blog_subtitle% | %meta_keywords% %page%'
  setting :tag_title_template,         :string, 'Tag: %name% | %blog_name% %page%'
  setting :tag_desc_template,          :string, '%name% | %blog_name% | %blog_subtitle% %page%'
  setting :author_title_template,      :string, '%author% | %blog_name%'
  setting :author_desc_template,       :string, '%author% | %blog_name% | %blog_subtitle%'
  setting :archives_title_template,    :string, 'Archives for %blog_name% %date% %page%'
  setting :archives_desc_template,     :string, 'Archives for %blog_name% %date% %page% %blog_subtitle%'
  setting :search_title_template,      :string, 'Results for %search% | %blog_name% %page%'
  setting :search_desc_template,       :string, 'Results for %search% | %blog_name% | %blog_subtitle% %page%'
  setting :statuses_title_template,    :string, 'Notes | %blog_name% %page%'
  setting :statuses_desc_template,     :string, 'Notes | %blog_name% | %blog_subtitle% %page%'
  setting :status_title_template,      :string, '%body% | %blog_name%'
  setting :status_desc_template,       :string, '%excerpt%'

  setting :custom_tracking_field,      :string, ''
  # setting :meta_author_template,       :string, "%blog_name% | %nickname%"

  setting :twitter_consumer_key,      :string, ''
  setting :twitter_consumer_secret,   :string, ''
  setting :custom_url_shortener,      :string, ''

  # The default Blog. This is the lowest-numbered blog, almost always
  # id==1. This should be the only blog as well.
  def self.default
    first
  rescue
    logger.warn 'You have no blog installed.'
    nil
  end

  # In settings with :article_id
  def ping_article!(settings)
    unless global_pings_enabled? && settings.key?(:url) && settings.key?(:article_id)
      throw :error, 'Invalid trackback or trackbacks not enabled'
    end
    settings[:blog_id] = id
    article = Article.find(settings[:article_id])
    unless article.allow_pings?
      throw :error, 'Trackback not saved'
    end
    article.trackbacks.create!(settings)
  end

  def global_pings_enabled?
    !global_pings_disable?
  end

  # Check that all required blog settings have a value.
  def configured?
    settings.key?('blog_name')
  end

  # The URL for a static file.
  def file_url(filename)
    if CarrierWave.configure { |config| config.storage == CarrierWave::Storage::Fog }
      filename
    else
      url_for "files/#{filename}", only_path: false
    end
  end

  def articles_matching(query, args = {})
    Article.search(query, args)
  end

  def per_page(format)
    if format.nil? || format == 'html'
      limit_article_display
    else
      limit_rss_display
    end
  end

  def rss_limit_params
    limit = limit_rss_display.to_i
    limit.zero? \
      ? {} \
      : { limit: limit }
  end

  def root_path
    split_base_url[:root_path]
  end

  def text_filter_object
    text_filter.to_text_filter
  end

  def urls_to_ping_for(article)
    urls_to_ping = []
    ping_urls.gsub(/ +/, '').split(/[\n\r]+/).map(&:strip).delete_if { |u| article.already_ping?(u) }.uniq.each do |url|
      urls_to_ping << article.pings.build('url' => url)
    end
    urls_to_ping
  end

  def has_twitter_configured?
    return false if twitter_consumer_key.nil? or twitter_consumer_secret.nil?
    return false if twitter_consumer_key.empty? or twitter_consumer_secret.empty?
    true
  end

  private

  def host_with_port
    split_base_url[:host_with_port]
  end

  def split_base_url
    unless @split_base_url
      unless base_url =~ /(https?):\/\/([^\/]*)(.*)/
        raise "Invalid base_url: #{base_url}"
      end
      @split_base_url = { protocol: $1, host_with_port: $2, root_path: $3.gsub(%r{/$}, '') }
    end
    @split_base_url
  end

end
