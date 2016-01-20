# coding: utf-8
# Methods added to this helper will be available to all templates in the application.
require 'digest/sha1'

module ApplicationHelper
  # Need to rewrite this one, quick hack to test my changes.
  def page_title
    @page_title
  end

  def render_sidebars(*sidebars)
    (sidebars.blank? ? Sidebar.order(:active_position) : sidebars).map do |sb|
      @sidebar = sb
      sb.parse_request(content_array, params)
      render_sidebar(sb)
    end.join
  rescue => e
    logger.error e
    logger.error e.backtrace.join("\n")
    I18n.t('errors.render_sidebar')
  end

  def render_sidebar(sidebar)
    render_to_string(partial: sidebar.content_partial, locals: sidebar.to_locals_hash, layout: false)
  end

  def articles?
    not Article.first.nil?
  end

  def trackbacks?
    not Trackback.first.nil?
  end

  def comments?
    not Comment.first.nil?
  end

  def render_to_string(*args, &block)
    controller.send(:render_to_string, *args, &block)
  end

  def link_to_permalink(item, title, anchor = nil, style = nil, nofollow = nil, only_path = false)
    options = {}
    options[:class] = style if style
    options[:rel] = 'nofollow' if nofollow
    link_to title, item.permalink_url(anchor, only_path), options
  end

  def avatar_tag(options = {})
    begin
      avatar_class = this_blog.plugin_avatar.constantize
    rescue NameError
      return ''
    end
    return '' unless avatar_class.respond_to?(:get_avatar)
    avatar_class.get_avatar(options)
  end

  def meta_tag(name, value, property = false)
    return tag :meta, name: name, content: value unless property || value.blank?
    tag :meta, property: name, content: value unless value.blank?
  end

  def onhover_show_admin_tools(type, id = nil)
    admin_id = "#admin_#{[type, id].compact.join('_')}"
    tag = []
    tag << %{ onmouseover="if (getCookie('publify_user_profile') == 'admin') { $('#{admin_id}').show(); }" }
    tag << %{ onmouseout="$('#{admin_id}').hide();" }
    tag.join ' '
  end

  def feed_title
    if @feed_title.present?
      @feed_title
    elsif @page_title.present?
      @page_title
    else
      this_blog.blog_name
    end
  end

  def html(content, what = :all, _deprecated = false)
    content.html(what)
  end

  def display_user_avatar(user, size = 'avatar', klass = 'alignleft')
    if user.resource.present?
      avatar_path = case size
                    when 'thumb'
                      user.resource.upload.thumb.url
                    when 'medium'
                      user.resource.upload.medium.url
                    when 'large'
                      user.resource.upload.large.url
                    else
                      user.resource.upload.avatar.url
                    end
      return if avatar_path.nil?
      avatar_url = avatar_path =~ /^http/ ? avatar_path : File.join(this_blog.base_url, avatar_path)
    elsif user.twitter_profile_image.present?
      avatar_url = user.twitter_profile_image
    end
    return unless avatar_url
    image_tag(avatar_url, alt: user.nickname, class: klass)
  end

  def author_picture(status)
    return if status.user.twitter_profile_image.nil? or status.user.twitter_profile_image.empty?
    return if status.twitter_id.nil? or status.twitter_id.empty?

    image_tag(status.user.twitter_profile_image, class: 'alignleft', alt: status.user.nickname)
  end

  def use_canonical
    "<link rel='canonical' href='#{this_blog.base_url + request.fullpath}' />".html_safe
  end

  def page_header_includes
    content_array.collect { |c| c.whiteboard }.collect do |w|
      w.select { |k, _v| k =~ /^page_header_/ }.collect do |_, v|
        v = v.chomp
        # trim the same number of spaces from the beginning of each line
        # this way plugins can indent nicely without making ugly source output
        spaces = /\A[ \t]*/.match(v)[0].gsub(/\t/, '  ')
        v.gsub!(/^#{spaces}/, '  ') # add 2 spaces to line up with the assumed position of the surrounding tags
      end
    end.flatten.uniq.join("\n")
  end

  def feed_atom
    feed_for('atom')
  end

  def feed_rss
    feed_for('rss')
  end

  def content_array
    if @articles
      @articles
    elsif @article
      [@article]
    elsif @page
      [@page]
    else
      []
    end
  end

  def display_article_date(article)
    date = article.published_at
    article_date = date.strftime("#{date.day.ordinalize} %B")
    article_date = "#{article_date} #{date.year}" if date.year != Date.today.year
    article_date
  end


  def display_date(date)
    l(date, format: this_blog.date_format)
  end

  def display_time(time)
    time.strftime(this_blog.time_format)
  end

  def display_date_and_time(timestamp)
    if this_blog.date_format == 'setting_date_format_distance_of_time_in_words'
      timeago_tag timestamp, date_only: false
    else
      "#{display_date(timestamp)}"
    end
  end

  def show_meta_keyword
    return unless this_blog.use_meta_keyword
    meta_tag 'keywords', @keywords unless @keywords.blank?
  end

  def this_blog
    @blog ||= Blog.default
  end

  def stop_index_robots?(blog)
    stop = (params[:year].present? || params[:page].present?)
    stop = blog.unindex_tags if controller_name == 'tags'
    stop = blog.unindex_categories if controller_name == 'categories'
    stop
  end

  def get_reply_context_url(reply)
    link_to(reply['user']['name'], reply['user']['entities']['url']['urls'][0]['expanded_url'])
  rescue
    link_to(reply['user']['name'], "https://twitter.com/#{reply['user']['name']}")
  end

  def get_reply_context_twitter_link(reply)
    link_to(display_date_and_time(reply['created_at'].to_time.in_time_zone),
            "https://twitter.com/#{reply['user']['screen_name']}/status/#{reply['id_str']}")
  end

  def latest_articles
    return @latest_articles if @latest_articles
    @latest_articles = Article.published.order('published_at DESC').limit(3)
    @latest_articles = @latest_articles.where('id != ?', @article) if @article
    @latest_articles
  end

  private

  def feed_for(type)
    if params[:action] == 'search'
      url_for(only_path: false, format: type, q: params[:q])
    elsif not @article.nil?
      @article.feed_url(type)
    elsif not @auto_discovery_url_atom.nil?
      instance_variable_get("@auto_discovery_url_#{type}")
    end
  end

  # fetches appropriate html content for RSS and ATOM feeds. Checks for:
  # - article being password protected
  # - hiding extended content on RSS. In this case if there is an excerpt we show the excerpt, or else we show the body
  def fetch_html_content_for_feeds(item, this_blog)
    if this_blog.hide_extended_on_rss
      if item.excerpt? and item.excerpt.length > 0 then
        item.excerpt
      else
        html(item, :body)
      end
    else
      html(item, :all)
    end
  end

end
