class ContentController < ApplicationController

  class ExpiryFilter
    def before(_controller)
      @request_time = Time.now
    end

    def after(controller)
      future_article =
        Article.where('published = ? AND published_at > ?', true, @request_time)
                .order('published_at ASC').first
       if future_article
         delta = future_article.published_at - Time.now
         controller.response.lifetime = (delta <= 0) ? 0 : delta
       end
    end
  end

  include LoginSystem

end
