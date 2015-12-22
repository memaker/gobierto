Rails.application.routes.draw do

  root 'pages#home'

  # statics
  get 'about' => 'pages#about'
  get 'request_access' => 'pages#request_access'

  if Rails.env.development?
    # root 'pages#index'
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  get 'search' => 'search#index'

  get '/budget_lines/:slug/:year/:code/:kind/:area' => 'budget_lines#show', as: :budget_line
  get '/places/:slug/:year' => 'places#show', as: :place
  get '/places/:slug/:year/:kind/:area' => 'places#budget', as: :place_budget

  namespace :api do
    get '/data/lines/:ine_code/:year/:what' => 'data#lines', as: :data_lines
    get '/data/widget/total_budget/:ine_code/:year' => 'data#total_budget', as: :data_total_budget
    get '/data/widget/total_budget_per_inhabitant/:ine_code/:year' => 'data#total_budget_per_inhabitant', as: :data_total_budget_per_inhabitant
    get '/data/widget/budget/:ine_code/:year/:code/:area/:kind' => 'data#budget', as: :data_budget
    get '/data/widget/budget_per_inhabitant/:year/:code/:area/:kind' => 'data#budget_per_inhabitant', as: :data_budget_per_inhabitant
    get '/data/widget/budget_percentage_over_total/:ine_code/:year/:code/:area/:kind' => 'data#budget_percentage_over_total', as: :data_budget_percentage_over_total
    get '/data/widget/budget_percentage_over_province/:ine_code/:year/:code/:area/:kind' => 'data#budget_percentage_over_province', as: :data_budget_percentage_over_province
    get '/data/widget/population/:ine_code/:year' => 'data#population', as: :data_population
  end

end
