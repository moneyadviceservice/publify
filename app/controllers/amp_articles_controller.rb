class AmpArticlesController < ActionController::Base
  def show
    if (@article = Article.find_by_permalink(params[:from])).present?
      # @comment     = Comment.new(article: @article, author: session[:author], email: session[:email])
      # @page_title  = @article.title_meta_tag.present? ? @article.title_meta_tag : @article.title
      # @description = @article.description_meta_tag
      # @keywords    = @article.tags.map { |g| g.name }.join(', ')
      # @feedback    = @article.published_feedback

      respond_to do |format|
        format.html do
        render 'articles/amp/show'
        end
      end
    else
      render 'errors/404', status: 404
    end
  end
end
