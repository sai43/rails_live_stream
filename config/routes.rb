LiveStreaming::Application.routes.draw do

  root to: 'messages#index'
  
  resources :messages do
    collection { get :events }
  end

  
end
