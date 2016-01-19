class ArticlesController < ContentController
  before_filter :login_required, only: :preview
  before_filter :auto_discovery_feed, only: [:show, :index]
  before_filter :verify_config

  layout 'default.html.erb', except: [:comment_preview, :trackback]

  cache_sweeper :blog_sweeper
  caches_page :index, :archives, :view_page, :redirect, if: Proc.new { |c| c.request.query_string == '' }

  helper :'admin/base'

  def index
    @page_title = this_blog.home_title_template.to_title(@articles, this_blog, params)
    @description = this_blog.home_desc_template.to_title(@articles, this_blog, params)
    @keywords = this_blog.meta_keywords
    @lead_campaign = Campaign.lead.last

    @articles = Content.published.where('type = ?', 'Article')
    @articles = @articles.limit(this_blog.per_page(params[:format]))

    respond_to do |format|
      format.html do
        auto_discovery_feed(only_path: false)
      end
      format.atom do
        render "index_atom_feed", layout: false
      end
      format.rss do
        auto_discovery_feed(only_path: false)
        render "index_rss_feed", layout: false
      end
      format.json do
        render "index_json_feed", layout: false
      end
    end
  end

  def search
    @articles = this_blog.articles_matching(params[:q], page: params[:page], per: 7)
    @page_title = this_blog.search_title_template.to_title(@articles, this_blog, params)
    @description = this_blog.search_desc_template.to_title(@articles, this_blog, params)

    if params[:q].blank?
      @page_title = @page_title.gsub(/^(\w|\s|%)*/, 'Search ')
      @description = @description.gsub(/^(\w|\s|%)*/, 'Search ')
    end
  end

  def preview
    @article = Article.last_draft(params[:id])
    @comment = Comment.new
    @page_title = @article.title_meta_tag.present? ? @article.title_meta_tag : @article.title
    render 'read'
  end

  def redirect
    if (@article = Article.find_by_permalink(params[:from])).present?
      @comment     = Comment.new(article: @article, author: session[:author], email: session[:email])
      @page_title  = @article.title_meta_tag.present? ? @article.title_meta_tag : @article.title
      @description = @article.description_meta_tag
      @keywords    = @article.tags.map { |g| g.name }.join(', ')

      auto_discovery_feed
      
      respond_to do |format|
        format.html { render "articles/#{@article.post_type}" }
        format.atom { render_feedback_feed('atom') }
        format.rss  { render_feedback_feed('rss') }
        format.xml  { render_feedback_feed('atom') }
      end
    elsif (redirect = Redirect.find_by_from_path(params[:from])).present?
      redirect_to redirect.full_to_path, status: 301
    else
      render 'errors/404', status: 404
    end
  end

  def archives
    @articles = Article.published.page(params[:page]).per(7)
    @page_title = this_blog.archives_title_template.to_title(@articles, this_blog, params)
    @keywords = this_blog.meta_keywords
    @description = this_blog.archives_desc_template.to_title(@articles, this_blog, params)
  end

  def comment_preview
    if (params[:comment][:body].blank? rescue true)
      render nothing: true
      return
    end

    headers['Content-Type'] = 'text/html; charset=utf-8'
    @comment = Comment.new(params[:comment])
  end

  def view_page
    if (@page = Page.find_by_name(Array(params[:name]).join('/'))) && @page.published?
      @page_title = @page.title
      @description = this_blog.meta_description
      @keywords = this_blog.meta_keywords
    else
      render 'errors/404', status: 404
    end
  end

  private

  def verify_config
    if  !this_blog.configured?
      redirect_to controller: 'setup', action: 'index'
    elsif User.count == 0
      redirect_to controller: 'accounts', action: 'signup'
    else
      return true
    end
  end

  def render_feedback_feed format
    @feedback = @article.published_feedback
    render "feedback_#{format}_feed", layout: false
  end

  def use_custom_header?
    action_name == 'index'
  end
end
