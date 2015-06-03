class NewsController < ArticlesController
  def show_article
    @article = Article.news.find_by(permalink: params[:id])
    raise ActiveRecord::RecordNotFound unless @article
    super
  end
end
