Rails.application.routes.draw do

  scope controller: 'styleguide', path: 'styleguide', as: 'styleguide'  do
    get '/', action: 'index'
    get 'show', action: 'show'
    get 'article_page', action: 'article_page'
    get 'home_page', action: 'home_page'
  end

  get 'articles.:format', to: 'articles#index', constraints: { format: 'rss' }, as: 'rss'
  get 'articles.:format', to: 'articles#index', constraints: { format: 'atom' }, as: 'atom'
  get 'articles.:format', to: 'articles#index', constraints: { format: 'json' }, as: 'json'

  scope controller: 'xml', path: 'xml' do
    get 'articlerss/:id/feed.xml', action: 'articlerss', format: false
    get 'commentrss/feed.xml', action: 'commentrss', format: false
    get 'trackbackrss/feed.xml', action: 'trackbackrss', format: false
  end

  get 'xml/:format', to: 'xml#feed', type: 'feed', constraints: { format: 'rss' }, as: 'xml'
  get 'sitemap.xml', to: 'xml#feed', format: 'googlesitemap', type: 'sitemap', as: 'sitemap_xml'
  get 'news-sitemap.xml', to: 'xml#news_feed', format: 'googlesitemap', type: 'news'

  scope controller: 'xml', path: 'xml', as: 'xml' do
    scope action: 'feed' do
      get ':format/feed.xml', type: 'feed'
      get ':format/:type/:id/feed.xml'
      get ':format/:type/feed.xml'
    end
  end

  get 'xml/rsd', to: 'xml#rsd', format: false
  get 'xml/feed', to: 'xml#feed'

  # CommentsController
  resources :comments do
    collection do
      match :preview, via: [:get, :post, :put, :delete]
    end
  end

  resources :trackbacks

  # I thinks it's useless. More investigating
  post 'trackbacks/:id/:day/:month/:year', to: 'trackbacks#create', format: false

  controller 'articles', format: false do
    # Initial search goes to /search?q=foo, subsequent pages go to /search/foo/pages/2
    get '/search(/:q/page/:page)', action: 'search', as: 'search'
    get '/archives/', action: 'archives'
    get '/pages/*name', action: 'view_page'
    get 'previews/:id', action: 'preview'
  end

  get '/news', to: 'tags#show', defaults: { id: 'news' }
  get '/news/:id', to: 'news#show_article'

  # SetupController
  match '/setup', to: 'setup#index', via: [:get, :post], format: false

  # Tags - note that the tags index has been forgotten about and is unstyled
  get '/tag/:id(/page/:page)', to: 'tags#show', as: :tag

  resources :author, only: :show

  # For the statuses
  get '/notes', to: 'notes#index', format: false
  get '/notes/page/:page', to: 'notes#index', format: false
  get '/note/:permalink', to: 'notes#show', format: false

  get '/humans', to: 'text#humans', format: 'txt'
  get '/robots', to: 'text#robots', format: 'txt'

  namespace :admin do
    mount Ckeditor::Engine => '/ckeditor', as: 'ckeditor'

    get '/', to: 'dashboard#index', as: 'dashboard'

    resources :popular_articles, only: [:new, :create]

    resources :sidebar, only: [:index, :update, :destroy] do
      collection do
        put :sortable
      end
    end

    resources :notes, except: [:new]
    resource :cache, controller: 'cache', only: [:show, :destroy]
    resources :campaigns, except: [:show]
  end

  # Work around the Bad URI bug
  %w(accounts files sidebar).each do |i|
    get "#{i}", to: "#{i}#index", format: false
    match "#{i}(/:action)", controller: i, format: false, via: [:get, :post, :put, :delete] # TODO: convert this magic catchers to resources item to close un-needed HTTP method
    match "#{i}(/:action(/:id))", controller: i, id: nil, format: false, via: [:get, :post, :put, :delete] # TODO: convert this magic catchers to resources item to close un-needed HTTP method
  end

  # Admin/XController
  %w(content profiles pages feedback resources sidebar textfilters users settings redirects seo post_types).each do |i|
    match "/admin/#{i}", to: "admin/#{i}#index", format: false, via: [:get, :post, :put, :delete] # TODO: convert this magic catchers to resources item to close un-needed HTTP method
    match "/admin/#{i}(/:action(/:id))", controller: "admin/#{i}", action: nil, id: nil, format: false, via: [:get, :post, :put, :delete] # TODO: convert this magic catchers to resources item to close un-needed HTTP method
  end

  match "/admin/articles/:article_id/feedback", to: "admin/feedback#index", format: false, via: :get, as: :article_feedback

  root to: 'articles#index', format: false

  get '*from', to: 'articles#show', format: false
end
