Rails.application.routes.draw do

  devise_for :members
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  mount ActionCable.server => '/cable'

  resources :projects do
    collection do
      get 'archived'
    end
    member do
      post 'add_member'
      post 'remove_member'
    end
  end
  
  resources :members do
    member do
      post 'lock'
      get 'qualification'
    end
    collection do
      patch 'update_password'
      get 'public'
      get 'departments'
      get 'annotations'
      get 'qualifications'
    end
  end

  resources :annotations
  resources :inquiries
  resources :people

  resources :fee_payments do
    collection do
      get 'reset_all'
      delete 'reset_all'
      post 'email'
    end
  end

  resources :courses do
    member do
      post 'email'
      post 'add_member/:member_id', to: 'courses#add_member', as: :add_member_to
      post 'remove_member/:member_id', to: 'courses#remove_member', as: :remove_member_from
    end
  end

  resources :consultations do
    member do
      post 'email'
    end
  end

  resources :bibliographies do
    resources :documents do
      member do
        get 'get_attachment'
        get 'thumbnail'
      end
    end
  end

  resources :events do
    collection do
      #get 'index'
      get 'export', defaults: { format: 'ics' }
      get 'calendar'
    end
    member do
      post 'add_member/:member_id', to: 'events#add_member', as: :add_member_to
      post 'remove_member/:member_id', to: 'events#remove_member', as: :remove_member_from

      patch 'attend', to: 'events#attend'
      patch 'unattend', to: 'events#unattend'
      post 'email'
    end
  end

  patch 'attendances/:id/permit', to: 'attendances#permit', as: :permit_attendance
  patch 'attendances/:id/unpermit', to: 'attendances#unpermit', as: :unpermit_attendance
  patch 'attendances/:id/award', to: 'attendances#award', as: :award_attendance
  patch 'attendances/:id/unaward', to: 'attendances#unaward', as: :unaward_attendance


  resources :tasks do
    collection do
      get 'done'
    end
    member do
      post 'close'
    end
  end

  get 'public_mandates', to: 'mandates#public_index', as: :public_mandates
  get 'public_people', to: 'people#public_index', as: :public_people
  get 'suggest_person', to: 'people#suggest', as: :suggest_person
  get 'suggest_member', to: 'members#suggest', as: :suggest_member

  get 'rights', to: 'members#index_rights', as: :members_rights
  get 'rights/:id/edit', to: 'members#edit_right', as: :edit_member_right
  patch 'rights/:id', to: 'members#update_right', as: :update_member_right

  resources :conversations do
    resources :messages, only: :create do
      get 'get_attachment'
      get 'thread'
    end
  end

  resources :mandates do
    resources :assignments, only: [:update, :destroy]
    patch 'apply', to: 'assignments#apply'
    patch 'unapply', to: 'assignments#unapply'
    member do
      post 'request_review'
      get 'get_attachment'
      post 'add_member/:member_id', to: 'mandates#add_member'
    end
  end
  get 'window', to: 'window#home', as: :window
  get 'window/detail/:access_code', to: 'window#detail', as: :window_detail
  post 'window/message', to: 'window#message', as: :window_message

  get 'departments/:id', to: 'departments#show', as: :departments # TODO is this still in use?

end