Rails.application.routes.draw do
  # The root page is kind of dynamic
  root 'meta_welcome#index'

  if Rails.env.development?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  # user and session management
  get 'login' => 'sessions#new', as: :login
  post 'sessions'  => 'sessions#create'
  delete 'logout' => 'sessions#destroy', as: :logout
  resources :users, only: [:new, :create] do
    collection do
      post 'identify'
    end
    member do
      get 'verify'
    end
  end
  resource :user, only: [:edit, :update]
  resources :password_resets, only: [:new, :create, :update, :edit]

  namespace :admin do
    root to: redirect('/admin/activities')
    resources :users, only: [:index, :edit, :update, :destroy] do
      post 'impersonate/:id' => 'users#impersonate', as: :impersonate, on: :collection
      post 'restore/:id' => 'users#restore', as: :restore, on: :collection
    end
    resource :site, only: [:edit, :update]
    resources :activities, only: [:index, :show]

    namespace :gobierto_cms, path: '/cms', module: 'gobierto_cms' do
      resources :attachments, only: [:index, :destroy, :create]
      resources :pages, except: [:show] do
        resources :attachments, only: [:index, :destroy]
        collection do
          put :batch_update
        end
      end
    end
  end

  localized do
    namespace :gobierto_sites, path: '/site', module: 'gobierto_sites' do
      constraints GobiertoSiteConstraint.new do
        root to: 'sites#show'

        # legal pages (TODO: we should merge them)
        get 'privacy' => 'pages#privacy'
        get 'legal' => 'pages#legal'
        get 'cookie_warning' => 'pages#cookie_warning'

        get 'budgets(/:year)' => 'budgets#index', as: :budgets
        resources :budget_lines, only: [:index]
      end
    end

    namespace :gobierto_participation, path: '/participation', module: 'gobierto_participation' do
      constraints GobiertoSiteConstraint.new do
        root to: 'participation#index'

        resources :ideas do
          resources :comments, only: [:create]
        end

        resources :consultations do
          resources :consultation_answers, only: [:create]
        end
      end
    end

    namespace :gobierto_cms, path: '/pages', module: 'gobierto_cms' do
      constraints GobiertoSiteConstraint.new do
        root to: 'pages#index'
        get ':id' => 'pages#show', as: :page
      end
    end
  end

  namespace :gobierto_budgets, path: '/', module: 'gobierto_budgets' do
    resources :featured_budget_lines, only: [:show]

    namespace :api do
      get '/data/lines/:ine_code/:year/:what' => 'data#lines', as: :data_lines
      get '/data/compare/:ine_codes/:year/:what' => 'data#compare', as: :data_compare
      get '/data/lines/budget_line/:ine_code/:year/:what/:kind/:code/:area' => 'data#lines', as: :data_lines_budget_line
      get '/data/compare/budget_line/:ine_codes/:year/:what/:kind/:code/:area' => 'data#compare', as: :data_compare_budget_lines
      get '/data/widget/total_budget/:ine_code/:year' => 'data#total_budget', as: :data_total_budget
      get '/data/widget/total_budget_per_inhabitant/:ine_code/:year' => 'data#total_budget_per_inhabitant', as: :data_total_budget_per_inhabitant
      get '/data/widget/budget/:ine_code/:year/:code/:area/:kind' => 'data#budget', as: :data_budget
      get '/data/widget/budget_execution/:ine_code/:year/:code/:area/:kind' => 'data#budget_execution', as: :data_budget_execution
      get '/data/widget/budget_per_inhabitant/:ine_code/:year/:code/:area/:kind' => 'data#budget_per_inhabitant', as: :data_budget_per_inhabitant
      get '/data/widget/budget_percentage_over_total/:ine_code/:year/:code/:area/:kind' => 'data#budget_percentage_over_total', as: :data_budget_percentage_over_total
      get '/data/widget/population/:ine_code/:year' => 'data#population', as: :data_population
      get '/data/widget/ranking/:year/:kind/:area/:variable(/:code)' => 'data#ranking', as: :data_ranking
      get '/data/widget/total_widget_execution/:ine_code/:year' => 'data#total_budget_execution', as: :data_total_budget_execution
      get '/data/widget/debt/:ine_code/:year' => 'data#debt', as: :data_debt

      get '/categories/:area/:kind' => 'categories#index'
      get '/places' => 'places#index'
    end

    constraints GobiertoBudgetsConstraint.new do
      root 'gobierto_budgets/pages#home'

      # statics
      get 'about' => 'pages#about'
      get 'pro' => 'pages#pro'
      get 'request_access' => 'pages#request_access'
      get 'contact_pro' => redirect('/users/new')
      get 'contact_citizen' => redirect('/users/new')
      get 'faq' => 'pages#faq'
      get 'legal/cookies' => 'pages#legal_cookies'
      get 'legal/legal' => 'pages#legal_legal'
      get 'legal/privacy' => 'pages#legal_privacy'
      get 'en' => 'pages#en'

      get 'search' => 'search#index'
      get 'categories/:slug/:year/:area/:kind' => 'search#categories', as: :search_categories
      get 'geocoder' => 'geocoder#index', as: :geocoder

      get '/budget_lines/:slug/:year/:code/:kind/:area' => 'budget_lines#show', as: :budget_line
      get '/budget_lines/:slug/:year/:code/:kind/:area/feedback/:question_id' => 'budget_lines#feedback', as: :budget_line_feedback
      get '/places/:slug' => 'places#show'
      get '/places/:slug/:year/execution' => 'places#explore_execution'
      get '/places/:slug/:year' => 'places#show', as: :place
      get '/places/:slug/:year/:kind/:area' => 'places#budget', as: :place_budget

      # compare
      get 'compare' => 'pages#compare', as: :compare
      get 'compare-new' => 'pages#compare-new'
      get '/compare/:slug_list/:year/:kind/:area' => 'places#compare', as: :places_compare

      get 'ranking' => 'pages#ranking'
      get '/ranking/:year/:kind/:area/:variable(/:code)' => 'places#ranking', as: :places_ranking
      get '/ranking/:year/population' => 'places#ranking', as: :population_ranking, defaults: {variable: 'population'}

      # feedback
      resources :answers, only: [:create]

      # follow place
      resources :subscriptions, only: [:create, :destroy]

    end
  end
end
