Rails.application.routes.draw do

  get 'budgets' => 'budgets#index', as: :budgets

end
