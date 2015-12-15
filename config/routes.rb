Rails.application.routes.draw do

  root to: redirect('/presupuestos')

  if Rails.env.development?
    # root 'pages#index'
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  get 'presupuestos' => 'budgets#index', as: :budgets
  get 'search' => 'search#index'

  get 'categories/economic/:kind' => 'categories#economic'

  namespace :api do
    get '/data/:place_id/:year/:kind/economic' => 'data#economic'
    get '/data/:place_id/:year/functional' => 'data#functional'
    get '/data/distribution' => 'data#distribution'
    get '/data/dispersion' => 'data#dispersion'
    get '/data/lines' => 'data#lines'
  end


  ## New code

  resources :places

end
