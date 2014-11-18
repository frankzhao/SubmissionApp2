Rails.application.routes.draw do
  get "admin/index"
  get "ldap/:uid" => 'ldap#query'
  resources :comments
  resources :submissions
  resources :assignments
  get "assignments/new/:course_id" => "assignments#new"
  resources :courses
  resources :groups

  get "users/:id", :to => "users#show", :as => "user"

  devise_for :users
  devise_scope :user do
    authenticated :user do
      root :to => 'courses#index'
    end
    unauthenticated :user do
      root :to => 'devise/sessions#new', as: :unauthenticated_root
    end
  end

end
