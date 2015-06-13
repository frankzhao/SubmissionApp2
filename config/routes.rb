Rails.application.routes.draw do
  get "admin/index"
  resources :comments
  resources :submissions
  resources :assignments
  resources :courses
  resources :groups, except: [:edit]
  resources :assignment_extensions, only: [:create, :destroy]

  get "users/notifications" => "notifications#list"
  delete "users/notifications" => "notifications#dismiss"
  get "users/:id", :to => "users#show", :as => "user"
  
  get "assignments/new/:course_id" => "assignments#new"
  get "assignments/data/:id" => "assignments#data"
  get "assignments/group_data/:id" => "assignments#group_data"
  get "assignments/:assignment_id/group/:group_id" => "assignments#groups"
  get "assignments/:assignment_id/extension/new" => "assignment_extensions#new"
  get "assignments/:assignment_id/download" => "assignments#download_all_submissions"
  get "assignments/:assignment_id/show_hidden_comments" => "assignments#show_hidden_comments"
  get "assignments/:assignment_id/hide_hidden_comments" => "assignments#hide_hidden_comments"
  get "assignments/:assignment_id/:group_id/download" => "assignments#download_all_submissions_for_group"
  get "assignments/:assignment_id/:group_id/download_archives" => "assignments#download_group_archives"
  get "assignments/:assignment_id/download_finals" => "assignments#download_all_finals"
  
  get "courses/:id/groups" => "courses#groups"
  get "courses/:id/groups/new" => "groups#new"
  post "courses/:id/groups" => "groups#create"
  #post "courses/:id/groups/edit" => "groups#edit"
  
  get "submissions/:assignment_id/new" => "submissions#new"
  get "submissions/:id/finalise" => "submissions#finalise"
  get "submissions/:id/download" => "submissions#download"
  get "submissions/:id/pdf" => "submissions#pdf"
  get "submissions/:id/pdf_comments" => "submissions#pdf_comments"
  
  get "/admin/become/:id" => "admin#become"
  get "/admin" => "admin#index"
  post "/admin" => "admin#form"

  devise_for :users
  devise_scope :user do
    authenticated :user do
      root :to => 'users#show'
    end
    unauthenticated :user do
      root :to => 'devise/sessions#new', as: :unauthenticated_root
    end
  end

end
