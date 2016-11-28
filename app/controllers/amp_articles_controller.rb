class AmpArticlesController < ActionController::Base
  def show
    if (@article = Article.find_by_permalink(params[:from])).present?
      render 'articles/amp/show'
    else
      render 'errors/404', status: 404
    end
  end
end
