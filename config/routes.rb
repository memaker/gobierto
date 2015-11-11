Rails.application.routes.draw do

  if Rails.env.development?
    # root 'pages#index'
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  get 'budgets' => 'budgets#index', as: :budgets

end
