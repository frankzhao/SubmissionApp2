Rails.application.routes.draw do
  get "admin/index"
  get "ldap/:uid" => 'ldap#query'
  get "comments/new"
  get "comments/create"
  get "comments/edit"
  get "comments/show"
  get "comments/destroy"
  get "submissions/new"
  get "submissions/create"
  get "submissions/edit"
  get "submissions/show"
  get "submissions/index"
  get "submissions/destroy"
  get "assignments/:id" => "assignments#show"
  get "assignments/new" => "assignments#new"
  get "assignments/new/:course_id" => "assignments#new"
  post "assignments/new" => "assignments#create"
  get "assignments/create"
  get "assignments/edit"
  get "assignments/show"
  get "assignments/index"
  get "assignments/destroy"
  get "courses/new" => "courses#new"
  post "courses/new" => "courses#create"
  get "courses/create"
  get "courses/edit"
  get "courses/:id" => "courses#show"
  get "courses" => "courses#index"
  get "courses/destroy"
  get "groups/new"
  get "groups/create"
  get "groups/edit"
  get "groups/show"
  get "groups" => "groups#index"
  get "groups/destroy"
  get "users/:id" => "users#show"

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
