Rails.application.routes.draw do

  root to: redirect('/presupuestos')

  if Rails.env.development?
    # root 'pages#index'
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  get 'presupuestos' => 'budgets#index', as: :budgets
  get 'search' => 'search#index'

  namespace :api do
    get '/data/:place_id/:year/economic' => 'data#economic'
    get '/data/:place_id/:year/functional' => 'data#functional'
  end

end
