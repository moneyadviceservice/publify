class TagsController < ContentController

  layout :pick_layout

  cache_sweeper :blog_sweeper
  caches_page :index, :show, if: Proc.new {|c|
    c.request.query_string == ''
  }

  def show
    @tag = Tag.find_by!(name: params[:id])
    @page_title   = this_blog.tag_title_template.to_title(@tag, this_blog, params)
    @description = this_blog.tag_title_template.to_title(@tag, this_blog, params)
    @keywords = ''
    @keywords << @tag.keywords unless @tag.keywords.blank?
    @keywords << this_blog.meta_keywords unless this_blog.meta_keywords.blank?
    @articles = @tag.articles.published.page(params[:page]).per(12)

    respond_to do |format|
      format.html do
        redirect_to this_blog.base_url, status: 301 if @articles.empty?
      end

      format.atom do
        @articles = @articles.per(this_blog.limit_rss_display)
        render 'articles/index'
      end

      format.rss do
        @articles = @articles.per(this_blog.limit_rss_display)
        render 'articles/index'
      end
    end
  end

  private

  def pick_layout
    request.format.html? ? 'default' : false
  end

end
