class ArticlesController < ContentController
  before_filter :check_for_redirect, only: :show
  before_filter :login_required, only: :preview

  layout :pick_layout

  cache_sweeper :blog_sweeper
  caches_page :index, :archives, :view_page, :redirect, if: Proc.new { |c| c.request.query_string == '' }

  helper :'admin/base'

  def index
    @page_title = this_blog.home_title_template.to_title(@articles, this_blog, params)
    @description = this_blog.home_desc_template.to_title(@articles, this_blog, params)
    @keywords = this_blog.meta_keywords
    @lead_campaign = Campaign.lead.last

    @articles = Content.published.where('type = ?', 'Article')
    @articles = @articles.page(params[:page]).per(this_blog.per_page(params[:format]))

    respond_to do |format|
      format.html
      format.atom
      format.rss
      format.json
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

  def show
    if (@article = Article.find_by_permalink(params[:from])).present?
      @comment     = Comment.new(article: @article, author: session[:author], email: session[:email])
      @page_title  = @article.title_meta_tag.present? ? @article.title_meta_tag : @article.title
      @description = @article.description_meta_tag
      @keywords    = @article.tags.map { |g| g.name }.join(', ')
      @feedback    = @article.published_feedback

      respond_to do |format|
        format.html do
          render 'articles/read'
        end
        format.atom do
          render 'articles/read'
        end
        format.rss do
          render 'articles/read'
        end
      end
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

  def pick_layout
    request.format.html? ? 'default' : false
  end

  def check_for_redirect
    if (redirect = Redirect.find_by_from_path(params[:from])).present?
      redirect_to redirect.full_to_path, status: 301
    end
  end

  def use_custom_header?
    action_name == 'index'
  end
end
