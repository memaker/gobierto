Rails.application.routes.draw do

  root to: redirect('/places/madrid/2015')

  if Rails.env.development?
    # root 'pages#index'
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  get 'presupuestos' => 'budgets#index', as: :budgets
  get 'search' => 'search#index'

  get 'categories/economic/:kind' => 'categories#economic'


  ## New code

  get '/places/:slug/:year' => 'places#show', as: :place
  get '/places/:slug/:year/:kind' => 'places#budget', as: :place_budget

  namespace :api do
    get '/data/treemap/:ine_code/:type/:year/:kind/:level' => 'data#treemap', as: :data_treemap
    get '/data/lines/:ine_code/:year/:what' => 'data#lines', as: :data_lines
    get '/data/widget/total_budget/:ine_code/:year' => 'data#total_budget', as: :data_total_budget
    get '/data/widget/budget_per_inhabitant/:ine_code/:year' => 'data#budget_per_inhabitant', as: :data_budget_per_inhabitant
    get '/data/widget/population/:ine_code/:year' => 'data#population', as: :data_population
  end

end
