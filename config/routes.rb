Rails.application.routes.draw do

  scope controller: 'styleguide', path: 'styleguide', as: 'styleguide'  do
    get '/', action: 'index', as: :index
    get 'show', action: 'show', as: :show
    get 'article_page', action: 'article_page', as: :article_page
    get 'home_page', action: 'home_page', as: :home_page
  end

  resources :comments, only: [:index, :create]

  get 'sitemap', to: 'sitemaps#show', constraints: { format: 'xml' }
  get 'news-sitemap', to: 'sitemaps#show', constraints: { format: 'xml' }, news: true

  get 'articles.:format', to: 'articles#index', constraints: { format: 'rss' }, as: 'rss'
  get 'articles.:format', to: 'articles#index', constraints: { format: 'atom' }, as: 'atom'
  get 'articles.:format', to: 'articles#index', constraints: { format: 'json' }, as: 'json'

  controller 'articles', format: false do
    # Initial search goes to /search?q=foo, subsequent pages go to /search/foo/pages/2
    get '/search(/:q/page/:page)', action: 'search', as: 'search'
    get '/archives/', action: 'archives', as: 'archives'
    get '/pages/*name', action: 'view_page', as: 'page'
    get 'previews/:id', action: 'preview', as: 'preview'
  end

  get '/news', to: 'tags#show', defaults: { id: 'news' }

  # Tags - note that the tags index has been forgotten about and is unstyled
  get '/tag/:id(/page/:page)', to: 'tags#show', as: :tag

  resources :author, only: :show

  # For the statuses
  get '/notes', to: 'notes#index', format: false
  get '/notes/page/:page', to: 'notes#index', format: false
  get '/note/:permalink', to: 'notes#show', as: :note, format: false

  get '/robots', to: 'text#robots', format: 'txt'

  mount Ckeditor::Engine => '/admin/ckeditor', as: 'ckeditor'

  namespace :admin do
    get '/', to: 'dashboard#index', as: 'dashboard'

    resources :popular_articles, only: [:new, :create]

    resources :notes, except: [:new]
    resource :cache, controller: 'cache', only: [:show, :destroy]
    resources :campaigns, except: [:show]

    resources :contents, path: :articles do
      collection do
        get :auto_complete_for_article_keywords
      end
      member do
        get :remove
      end
    end

    resources :pages do
      member do
        get :remove
      end
    end

    resources :feedbacks, except: [:new, :create], path: :feedback do
      collection do
        post :bulkops
      end
      member do
        get :remove
        get :change_state
      end
    end

    resources :resources, only: [:index, :create, :destroy] do
      member do
        get :remove
      end
    end

    resources :redirects do
      member do
        get :remove
      end
    end

    # Looks like removal has been omitted from the interface
    resources :users, except: :destroy

    get '/settings/general', to: 'settings#general', as: :general_settings
    get '/settings/write', to: 'settings#write', as: :write_settings
    get '/settings/feedback', to: 'settings#feedback', as: :feedback_settings
    get '/settings/display', to: 'settings#display', as: :display_settings
    get '/settings/seo', to: 'settings#seo', as: :seo_settings
    get '/settings/titles', to: 'settings#titles', as: :title_settings
    post '/settings/update', to: 'settings#update', as: :update_settings

    resource :profile, only: [:edit, :update]
  end

  get '/accounts', to: redirect("#{Rails.application.config.relative_url_root}/accounts/login")
  get '/accounts/login', to: 'accounts#login', as: :login
  post '/accounts/login', to: 'accounts#login'
  get '/accounts/logout', to: 'accounts#logout', as: :logout
  get '/accounts/recover-password', to: 'accounts#recover_password', as: :recover_password
  post '/accounts/recover-password', to: 'accounts#recover_password'

  root to: 'articles#index', format: false

  get '*from/amp', to: 'amp_articles#show', as: :amp_article
  get '*from', to: 'articles#show', as: :article
end
