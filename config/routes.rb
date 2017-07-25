Rails.application.routes.draw do
  resources :comments
  resources :submissions
  resources :assignments
  resources :courses
  resources :groups, except: [:edit]
  resources :assignment_extensions, only: [:create, :destroy]

  get "admin/index"

  resources :users, only: :show do
    collection do
      get '/', action: :me

      resources :notifications, only: [:index, :destroy]
    end
  end

  get "assignments/new/:course_id" => "assignments#new"
  get "assignments/data/:id" => "assignments#data"
  get "assignments/group_data/:id" => "assignments#group_data"
  get "assignments/:assignment_id/group/:group_id" => "assignments#groups"
  get "assignments/:assignment_id/extension/new" => "assignment_extensions#new", as: 'new_assignment_extension'
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
  
  get "uploads/*path" => "uploads#download"

  
  get "submissions/:assignment_id/new" => "submissions#new"
  get "submissions/:id/finalise" => "submissions#finalise"
  get "submissions/:id/download" => "submissions#download"
  get "submissions/:id/pdf" => "submissions#pdf"
  get "submissions/:id/pdf_comments" => "submissions#pdf_comments"
  get "submission/:id/contents" => "submissions#contents", as: "submission_contents"
  post "submissions/check_result" => "submissions#check_result"
  
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
