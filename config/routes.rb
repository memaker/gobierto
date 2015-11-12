Rails.application.routes.draw do

  root to: redirect('/presupuestos')

  if Rails.env.development?
    # root 'pages#index'
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  get 'presupuestos' => 'budgets#index', as: :budgets

end
