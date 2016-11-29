class AmpArticlesController < ActionController::Base
  def show
    if (@article = Article.find_by_permalink(params[:from])).present?
      if @article.supports_amp? || params[:no_redirect]
        render 'articles/amp/show'
      else
        redirect_to article_url(@article.permalink)
      end
    else
      render 'errors/404', status: 404
    end
  end
end
