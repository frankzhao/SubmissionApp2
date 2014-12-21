Rails.application.routes.draw do
  get "admin/index"
  resources :comments
  resources :submissions
  resources :assignments
  resources :courses
  resources :groups

  get "users/notifications" => "notifications#list"
  delete "users/notifications" => "notifications#dismiss"
  get "users/:id", :to => "users#show", :as => "user"
  
  get "assignments/new/:course_id" => "assignments#new"
  get "assignments/data/:id" => "assignments#data"
  get "assignments/:assignment_id/group/:group_id" => "assignments#groups"
  
  get "courses/:id/groups" => "courses#groups"
  get "courses/:id/groups/new" => "groups#new"
  post "courses/:id/groups" => "groups#create"
  
  get "submissions/:assignment_id/new" => "submissions#new"
  get "submissions/:id/finalise" => "submissions#finalise"
  
  get "/admin" => "admin#index"
  post "/admin" => "admin#form"

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
