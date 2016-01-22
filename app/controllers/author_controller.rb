class AuthorController < ContentController

  layout :pick_layout

  def show
    if (@author = User.find_by_login(params[:id])).present?
      @articles = @author.articles.published.page(params[:page]).per(this_blog.per_page(params[:format]))

      respond_to do |format|
        format.html do
          @page_title = this_blog.author_title_template.to_title(@author, this_blog, params)
          @keywords = this_blog.meta_keywords
          @description = this_blog.author_desc_template.to_title(@author, this_blog, params)
        end
        format.rss
        format.atom
      end
    else
      render 'errors/404', status: 404
    end
  end

  private

  def pick_layout
    request.format.html? ? 'default' : false
  end

end
