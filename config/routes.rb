Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :users

  devise_scope :user do #as :user do
    get 'users/edit', to: 'devise/registrations#edit', as: :edit_user_registration
    patch 'users', to: 'devise/registrations#update', as: :user_registration
  end

  root to: 'documents#index'

  resources :documents, only: %i[index show] do
    # TO KEEP: initial version to add folders or documents to shared list directly
    # patch :add_to_shared_list, on: :member
    resources :shared_lists do
      post :create_and_attach_document, on: :collection
    end
    resources :document_shared_lists, only: %i[create]
    member do
      resources :shared_documents, only: %i[new create]
    end
  end

  resources :folders, only: %i[index show] do
    patch :download, on: :member
    # TO KEEP: initial version to add folders or documents to shared list directly
    # patch :add_to_shared_list, on: :member
    resources :shared_lists do
      post :create_and_attach_folder, on: :collection
    end
    resources :folder_shared_lists, only: %i[create]
    member do
      resources :shared_folders, only: %i[new create]
    end
  end
  resources :shared_lists, only: %i[index show] do
    patch :add_contacts, on: :member
  end

  # -------- ADMIN ROUTES ---------
  authenticate :user, ->(user) { user.admin } do
    namespace :admin do
      resources :users, only: %i[index create destroy]
      resources :documents, only: %i[new create edit update destroy] do
        patch :add_to_folder, on: :member
        patch :validate
      end
      resources :folders, only: %i[destroy]
    end
  end

  # -------- PUBLIC ROUTES ---------
  namespace :public do
    root to: 'pages#home'
    resources :shared_lists, param: :code, only: %i[show] do
      resources :folders, only: %i[show]
      resources :documents, only: %i[show]
    end
    resources :shared_documents, param: :code, only: %i[show]
    resources :shared_folders, param: :code, only: %i[show] do
      resources :folders, only: %i[show]
      resources :documents, only: %i[show]
    end
  end
end
