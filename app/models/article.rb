# coding: utf-8
require 'uri'
require 'net/http'

class Article < Content
  include PublifyGuid
  include ConfigManager

  serialize :settings, Hash

  content_fields :body, :extended

  validates_uniqueness_of :guid
  validates_presence_of :title

  has_many :pings, -> { order('created_at ASC') }, dependent: :destroy
  has_many :trackbacks, -> { order('created_at ASC') }, dependent: :destroy
  has_many :feedback, -> { order('created_at DESC') }
  has_many :resources, -> { order('created_at DESC') }, dependent: :nullify
  has_many :triggers, as: :pending_item
  has_many :comments, -> { order('created_at ASC') }, dependent: :destroy do
    # Get only ham or presumed_ham comments
    def ham
      where(state: ['presumed_ham', 'ham'])
    end

    # Get only spam or presumed_spam comments
    def spam
      where(state: ['presumed_spam', 'spam'])
    end
  end

  has_many :published_comments,    -> { where(published: true).order('created_at ASC') }, class_name: 'Comment'
  has_many :published_trackbacks,  -> { where(published: true).order('created_at ASC') }, class_name: 'Trackback'
  has_many :published_feedback,    -> { where(published: true).order('created_at ASC') }, class_name: 'Feedback'

  has_and_belongs_to_many :tags, join_table: 'articles_tags'

  before_create :create_guid
  before_save :set_published_at, :set_permalink
  after_save :post_trigger, :keywords_to_tags, :shorten_url

  scope :drafts, lambda { where(state: 'draft').order('created_at DESC') }
  scope :child_of, lambda { |article_id| where(parent_id: article_id) }
  scope :published_at, lambda { |time_params| published.where(published_at: PublifyTime.delta(*time_params)).order('published_at DESC') }
  scope :published_since, lambda { |time| published.where('published_at > ?', time).order('published_at DESC') }
  scope :withdrawn, lambda { where(state: 'withdrawn').order('published_at DESC') }
  scope :pending, lambda { where('state = ? and published_at > ?', 'publication_pending', Time.now).order('published_at DESC') }

  scope :bestof, ->() {
    joins(:feedback)
      .where('feedback.published' => true, 'feedback.type' => 'Comment',
            'contents.published' => true)
      .group('contents.id')
      .order('count(feedback.id) DESC')
      .select('contents.*, count(feedback.id) as comment_count')
      .limit(5)
  }

  scope :exclude_news, lambda {
    sub_query = Article.joins(:tags).where(tags: {name: 'news'})
    where.not(id: sub_query)
  }

  scope :news, lambda {
    joins(:tags).where(tags: {name: 'news'})
  }

  attr_accessor :keywords

  include Article::States

  has_state(
    :state,
    valid_states: [:new, :draft, :publication_pending, :just_published, :published, :just_withdrawn, :withdrawn],
    initial_state: :new,
    handles: [:withdraw, :post_trigger, :send_pings, :send_notifications, :published_at=, :published=, :just_published?]
  )

  def set_permalink
    return if state == 'draft' || permalink.present?
    self.permalink = title.to_permalink
  end

  def has_child?
    Article.exists?(parent_id: id)
  end

  def post_type
    _post_type = read_attribute(:post_type)
    _post_type = 'read' if _post_type.blank?
    _post_type
  end

  def self.last_draft(article_id)
    article = Article.find(article_id)
    while article.has_child?
      article = Article.child_of(article.id).first
    end
    article
  end

  def self.search_with(params)
    params ||= {}
    scoped = super(params)
    if ['no_draft', 'drafts', 'published', 'withdrawn', 'pending'].include?(params[:state])
      scoped = scoped.send(params[:state])
    end

    scoped.order('created_at DESC')
  end

  def save_attachments!(files)
    files ||= {}
    files.values.each { |f| self.save_attachment!(f) }
  end

  def save_attachment!(file)
    resources << Resource.create_and_upload(file)
  rescue => e
    logger.info(e.message)
  end

  def really_send_pings
    return unless blog.send_outbound_pings

    blog.urls_to_ping_for(self).each do |url_to_ping|
      begin
        url_to_ping.send_weblogupdatesping(blog.base_url, permalink_url)
      rescue Exception => e
        logger.error(e)
        # in case the remote server doesn't respond or gives an error,
        # we should throw an xmlrpc error here.
      end
    end

    html_urls_to_ping.each do |url_to_ping|
      begin
        url_to_ping.send_pingback_or_trackback(permalink_url)
      rescue Exception => exception
        logger.error(exception)
        # in case the remote server doesn't respond or gives an error,
        # we should throw an xmlrpc error here.
      end
    end
  end

  def next
    Article.where('published_at > ?', published_at).order('published_at asc').limit(1).first
  end

  def previous
    Article.where('published_at < ?', published_at).order('published_at desc').limit(1).first
  end

  def self.find_by_published_at
    result = select('published_at').where('published_at is not NULL').where(type: 'Article')
    result.map { |d| [d.published_at.strftime('%Y-%m')] }.uniq
  end

  # Fulltext searches the body of published articles
  def self.search(query, args = {})
    query_s = query.to_s.strip
    if !query_s.empty? && args.empty?
      Article.searchstring(query)
    elsif !query_s.empty? && !args.empty?
      Article.searchstring(query).page(args[:page]).per(args[:per])
    else
      Article.none.page
    end
  end

  def keywords_to_tags
    Tag.create_from_article!(self)
  end

  def interested_users
    User.where(notify_on_new_articles: true)
  end

  def notify_user_via_email(user)
    if user.notify_via_email?
      EmailNotify.send_article(self, user)
    end
  end

  def comments_closed?
    !(allow_comments? && in_feedback_window?)
  end

  def html_urls
    urls = Array.new
    html.gsub(/<a\s+[^>]*>/) do |tag|
      if (tag =~ /\bhref=(["']?)([^ >"]+)\1/)
        urls.push($2.strip)
      end
    end
    urls.uniq
  end

  def pings_closed?
    !(allow_pings? && in_feedback_window?)
  end

  # check if time to comment is open or not
  def in_feedback_window?
    blog.sp_article_auto_close.zero? ||
      published_at.to_i > blog.sp_article_auto_close.days.ago.to_i
  end

  def content_fields
    [:body, :extended]
  end

  # The web interface no longer distinguishes between separate "body" and
  # "extended" fields, and instead edits everything in a single edit field,
  # separating the extended content using "\<!--more-->".
  def body_and_extended
    if extended.nil? || extended.empty?
      body
    else
      body + "\n<!--more-->\n" + extended
    end
  end

  # Split apart value around a "\<!--more-->" comment and assign it to our
  # #body and #extended fields.
  def body_and_extended= value
    parts = value.split(/\n?<!--more-->\n?/, 2)
    self.body = parts[0]
    self.extended = parts[1] || ''
  end

  def add_comment(params)
    comments.build(params)
  end

  def access_by?(user)
    user.admin? || user_id == user.id
  end

  def already_ping?(url)
    pings.map(&:url).include?(url)
  end

  def allow_comments?
    return allow_comments unless allow_comments.nil?
    blog.default_allow_comments
  end

  def allow_pings?
    return allow_pings unless allow_pings.nil?
    blog.default_allow_pings
  end

  protected

  def set_published_at
    if published and self[:published_at].nil?
      self[:published_at] = created_at || Time.now
    end
  end

  private

  def html_urls_to_ping
    urls_to_ping = []
    html_urls.delete_if { |url| already_ping?(url) }.uniq.each do |url_to_ping|
      urls_to_ping << pings.build('url' => url_to_ping)
    end
    urls_to_ping
  end
end
