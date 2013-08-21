SampleApi::Application.routes.draw do
  namespace :api do
    namespace :v1 do
    	post 'products/query' => 'products#query'   
      resources :products, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
