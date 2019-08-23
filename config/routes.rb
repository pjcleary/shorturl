Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # send / to the form to create a new short url
  root 'shortener#new'
  resources :shortener
end
