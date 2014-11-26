Rails.application.routes.draw do
  get "admin/index"
  get "ldap/:uid" => 'ldap#query'
  resources :comments
  resources :submissions
  resources :assignments
  resources :courses
  resources :groups

  get "users/notifications" => "notifications#list"
  delete "users/notifications" => "notifications#dismiss"

  get "users/:id", :to => "users#show", :as => "user"
  get "assignments/new/:course_id" => "assignments#new"
  get "courses/:id/groups" => "courses#groups"

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
