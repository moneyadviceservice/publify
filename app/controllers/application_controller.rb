# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require File.join(Rails.root, 'lib', 'popular_article')

class ApplicationController < ActionController::Base

  include ::LoginSystem
  protect_from_forgery only: [:edit, :update, :delete]

  before_filter :reset_local_cache, :fire_triggers, :set_paths
  before_filter :generate_popular_articles
  after_filter :reset_local_cache

  class << self
    unless self.respond_to? :template_root
      def template_root
        ActionController::Base.view_paths.last
      end
    end
  end

  protected

  def set_paths
    Dir.glob(File.join(::Rails.root.to_s, "lib", "*_sidebar/app/views")).select do |file|
      append_view_path file
    end
  end

  def fire_triggers
    Trigger.fire
  end

  def reset_local_cache
    if !session
      session session: new
    end
    @current_user = nil
  end

  # The base URL for this request, calculated by looking up the URL for the main
  # blog index page.
  def blog_base_url
    url_for(controller: '/articles').gsub(%r{/$}, '')
  end

  def add_to_cookies(name, value, path = nil, _expires = nil)
    cookies[name] = { value: value, path: path || "/#{controller_name}", expires: 6.weeks.from_now }
  end

  def this_blog
    @blog ||= Blog.default
  end

  def use_custom_header?
    false
  end

  helper_method :use_custom_header?

  def ssl_available?
    Rails.env.production?
  end

  def use_custom_header?
    false
  end
  helper_method :use_custom_header?

  def generate_popular_articles
    @popular_articles = if last = MostPopularArticle.last
      last.articles
    else
      []
    end
  end
end
