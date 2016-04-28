class SitemapsController < ApplicationController
  caches_page :feed, if: Proc.new {|c|
    c.request.query_string == ''
  }

  def show
    respond_to do |format|
      format.xml do
        if params[:news]
          @items = Article.find_already_published(1000).news.where('published_at > ?', Time.now - 48.hours)
        else
          @items = Article.exclude_news.find_already_published(1000)
          @items += Page.find_already_published(1000)
          @items += Tag.find_all_with_article_counters unless this_blog.unindex_tags
        end
      end
    end
  end

end
