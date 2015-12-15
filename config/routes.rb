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


  ## New code

  resources :places

  namespace :api do
    get '/data/treemap/:ine_code/:type/:year/:kind/:level' => 'data#treemap', as: :data_treemap
  end

end
