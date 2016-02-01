Rails.application.routes.draw do
  root 'pages#home'

  if Rails.env.development?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  # statics
  get 'about' => 'pages#about'
  get 'pro' => 'pages#pro'
  get 'request_access' => 'pages#request_access'
  get 'contact_pro' => 'pages#contact_pro'
  get 'contact_citizen' => 'pages#contact_citizen'
  get 'faq' => 'pages#faq'
  get 'legal/cookies' => 'pages#legal_cookies'
  get 'legal/legal' => 'pages#legal_legal'
  get 'legal/privacy' => 'pages#legal_privacy'

  # user and session management
  get 'login' => 'sessions#new', as: :login
  post 'sessions'  => 'sessions#create'
  delete 'logout' => 'sessions#destroy', as: :logout
  resources :users, only: [:new, :create] do
    member do
      get 'verify'
    end
  end
  resource :user, only: [:edit, :update]
  resources :password_resets, only: [:new, :create, :update, :edit]

  get 'search' => 'search#index'
  get 'categories/:slug/:year/:area/:kind' => 'search#categories', as: :search_categories
  get 'geocoder' => 'geocoder#index', as: :geocoder

  get '/budget_lines/:slug/:year/:code/:kind/:area' => 'budget_lines#show', as: :budget_line
  get '/budget_lines/:slug/:year/:code/:kind/:area/feedback/:question_id' => 'budget_lines#feedback', as: :budget_line_feedback
  get '/places/:slug/:year' => 'places#show', as: :place
  get '/places/:slug/:year/:kind/:area' => 'places#budget', as: :place_budget

  # compare
  get 'compare' => 'pages#compare'
  get '/compare/:slug_list/:year/:kind/:area' => 'places#compare', as: :places_compare

  get 'ranking' => 'pages#ranking'
  get '/ranking/:year/:kind/:area/:variable(/:code)' => 'places#ranking', as: :places_ranking
  get '/ranking/:year/population' => 'places#ranking', as: :population_ranking, defaults: {variable: 'population'}

  # feedback
  resources :answers, only: [:create]

  # follow place
  resources :subscriptions, only: [:create, :destroy]

  namespace :api do
    get '/data/lines/:ine_code/:year/:what' => 'data#lines', as: :data_lines
    get '/data/compare/:ine_codes/:year/:what' => 'data#compare', as: :data_compare
    get '/data/lines/budget_line/:ine_code/:year/:what/:kind/:code/:area' => 'data#lines', as: :data_lines_budget_line
    get '/data/compare/budget_line/:ine_codes/:year/:what/:kind/:code/:area' => 'data#compare', as: :data_compare_budget_lines
    get '/data/widget/total_budget/:ine_code/:year' => 'data#total_budget', as: :data_total_budget
    get '/data/widget/total_budget_per_inhabitant/:ine_code/:year' => 'data#total_budget_per_inhabitant', as: :data_total_budget_per_inhabitant
    get '/data/widget/budget/:ine_code/:year/:code/:area/:kind' => 'data#budget', as: :data_budget
    get '/data/widget/budget_per_inhabitant/:ine_code/:year/:code/:area/:kind' => 'data#budget_per_inhabitant', as: :data_budget_per_inhabitant
    get '/data/widget/budget_percentage_over_total/:ine_code/:year/:code/:area/:kind' => 'data#budget_percentage_over_total', as: :data_budget_percentage_over_total
    get '/data/widget/budget_percentage_over_province/:ine_code/:year/:code/:area/:kind' => 'data#budget_percentage_over_province', as: :data_budget_percentage_over_province
    get '/data/widget/population/:ine_code/:year' => 'data#population', as: :data_population

    get '/categories/:area/:kind' => 'categories#index'
    get '/places' => 'places#index'
  end

end
