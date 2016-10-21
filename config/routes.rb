Rails.application.routes.draw do

  resources :bids, param: :bid_id
  resources :categories, param: :category_id
  resources :products, param: :product_id
  
  # Application root
  root 'application#index'

end
