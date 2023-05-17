# frozen_string_literal: true

Rails.application.routes.draw do
  direct :rails_public_blob do |blob|
    # Preserve the behaviour of `rails_blob_url` inside these environments
    # where S3 or the CDN might not be configured
    if Rails.env.development? || Rails.env.test?
      route =
        # ActiveStorage::VariantWithRecord was introduced in Rails 6.1
        # Remove the second check if you're using an older version
        if blob.is_a?(ActiveStorage::Variant)
          :rails_representation
        else
          :rails_blob
        end
      route_for(route, blob)
    else
      # Use an environment variable instead of hard-coding the CDN host
      File.join(ENV.fetch('CDN_HOST'), blob.key)
    end
  end

  # webhooks
  post 'webhooks/:key', to: 'webhooks#index'
  post 'webhooks/push', to: 'webhooks#push'

  # surveys
  get 'surveys/:code/:friend_id', to: 'surveys#form', as: 'new_survey_answer_form'
  post 'surveys/:code/:friend_id', to: 'surveys#answer', as: 'survey_answer_form'
  get 'surveys/:code', to: 'surveys#show'
  get 'surveys/:code/:friend_id/answer_success', to: 'surveys#answer_success', as: 'survey_answer_success'
  get 'surveys/:code/:friend_id/answer_error', to: 'surveys#answer_error', as: 'survey_answer_error'
  get 'surveys/:code/:friend_id/already_answer', to: 'surveys#already_answer', as: 'survey_already_answer'
  post 'surveys/precheckin/:code/:friend_id', to: 'surveys#precheckin', as: 'survey_precheckin_form'
  post 'surveys/precheckin_answer/:code/:friend_id', to: 'surveys#precheckin_answer', as: 'survey_precheckin_answer_form'
  # reservations
  get 'reservations/precheckin_form/:friend_line_id', to: 'reservations#precheckin_form', as: 'reservation_precheckin_form'
  get 'reservations/inquiry_form/:friend_line_id', to: 'reservations#inquiry_form', as: 'reservation_inquiry_form'
  get 'reservations/precheckin_success', to: 'reservations#precheckin_success', as: 'reservation_precheckin_success'
  get 'reservations/inquiry_success', to: 'reservations#inquiry_success', as: 'reservation_inquiry_success'
  post 'reservations/precheckin_detail/:friend_line_id',  to: 'reservations#precheckin_detail', as: 'reservation_precheckin_detail'
  post 'reservations/precheckin/:friend_line_id',  to: 'reservations#precheckin', as: 'reservation_precheckin'
  post 'reservations/inquire/:friend_line_id',  to: 'reservations#inquire', as: 'reservation_inquire'
  post 'reservations/callback', to: 'reservations#callback', as: 'reservation_callback'
  # service_reviews
  get 'reviews/new/:friend_line_id', to: 'reviews#new', as: 'review_new'
  post 'reviews/:friend_line_id', to: 'reviews#create', as: 'review_create'
  get 'reviews/result', to: 'reviews#result', as: 'review_result'
  resources :review_questions, only: :index

  # contacts
  get 'contacts/new/:friend_line_id', to: 'contacts#new', as: 'contact_new'
  get 'contacts/result', to: 'contacts#result', as: 'contact_result'
  resources :contacts, only: :create do
    collection do
      get :confirm_reservation
      post :confirmed_reservation
      post :cancel_reservation
      get :confirm_reservation_result
    end
  end

  # medias
  get 'medias/:id/content', to: 'medias#variant'
  get 'medias/:id/content/:size', to: 'medias#variant'

  # url click measurement
  get 'sites/:code', to: 'sites#statistic', as: :site_statistic

  # Stream route
  # Sample url set for stream route and QR code: https://example.com/stream_route_detail/V7WHX8
  # Sample url set for liff app and line login app: https://example.com/stream_route_detail
  get '/stream_route_detail', to: 'stream_routes#show', as: 'stream_route_detail'
  # use stream_route_code, but not code as parameter, because line login also return a code parameter
  get '/stream_route_detail/:stream_route_code', to: 'stream_routes#show', as: 'stream_route_detail_with_code'

  # User
  constraints Subdomain::UserConstraint.new do
    root to: 'user/home#index'
    devise_for :users, path: Subdomain::UserConstraint.path, controllers: {
      sessions: 'user/sessions',
      passwords: 'user/passwords'
    }
    devise_scope :admin do
      get 'user/password/sent', to: 'user/passwords#sent', as: :new_user_password_sent
      get 'user/password/expired', to: 'user/passwords#expired', as: :new_user_password_expired
    end
    namespace :user, path: Subdomain::UserConstraint.path do
      root to: 'home#index'
      get '/bot/setup', to: 'bot#setup'
      post '/bot/register', to: 'bot#register'
      resources :home, only: [:index] do
        get :announcements, on: :collection
      end
      resources :staffs do
        get :all, on: :collection
      end
      resources :channels do
        member do
          get :scenarios
          post :update_last_seen
          post :assign
          post :unassign
        end
        resources :messages do
          collection do
            post :send_scenario
            post :send_template
          end
        end
      end
      resources :friends do
        collection do
          get :search
          get :export
        end
        member do
          post :toggle_locked
          post :toggle_visible
          get :reminders
          post :set_reminder
          get :variables
        end
      end
      resources :broadcasts do
        get :search, on: :collection
        post :copy, on: :member
      end
      resources :scenarios do
        collection do
          get :search
          get :manual
        end
        resources :messages, controller: 'scenario_messages' do
          post :import, on: :collection
        end
        post :copy, on: :member
        post :send_to_testers, on: :member
      end
      resources :auto_responses do
        post :copy, on: :member
      end
      resources :templates do
        post :copy, on: :member
      end
      resources :rich_menus do
        post :copy, on: :member
      end
      resources :surveys do
        member do
          get :answered_users
          get :responses
          post :copy
          post :toggle_status
          get '/:friend_id/responses', to: 'surveys#friend_responses'
          get :export
        end
      end
      resources :reminders do
        member do
          post :copy
        end
        resources :episodes
      end
      resources :reservations
      resources :precheckins
      resources :reviews, only: :index
      resources :variables do
        member do
          post :copy
        end
      end
      resources :folders
      resources :tags
      get '/emojis/:pack_id', to: 'emojis#show'
      resources :medias do
        post :bulk_delete, on: :collection
        member do
          get '/content', to: 'medias#variant'
        end
      end
      resources :setting, only: [:index] do
        get :edit, on: :collection
        patch :update, on: :collection
        get :friends, on: :member
      end
      # url click measurement
      resources :sites do
        member do
          get :scenarios, defaults: { format: :json }
          get :broadcasts, defaults: { format: :json }
        end
      end
      resources :stream_routes do
        member do
          post 'copy'
        end
      end
    end
  end

  # Admin
  constraints Subdomain::AdminConstraint.new do
    devise_for :admins, path: Subdomain::AdminConstraint.path, controllers: {
      sessions: 'admin/sessions',
      passwords: 'admin/passwords'
    }
    devise_scope :admin do
      get 'admin/password/sent', to: 'admin/passwords#sent', as: :new_admin_password_sent
      get 'admin/password/expired', to: 'admin/passwords#expired', as: :new_admin_password_expired
    end
    namespace :admin, path: Subdomain::AdminConstraint.path do
      root to: 'accounts#index'
      resources :announcements do
        get :search, on: :collection
        post :upload_image,  on: :collection
      end
      resources :accounts
      resources :agencies do
        get :search, on: :collection
        get :sso, on: :member
      end
      resource :profile, only: %i(edit update)
    end

    require 'sidekiq/web'
    require 'sidekiq-scheduler/web'
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == ENV['BASIC_AUTH_ID'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
    mount Sidekiq::Web => '/sidekiq'
  end

  # Agency
  constraints Subdomain::AgencyConstraint.new do
    devise_for :agencies, path: Subdomain::AgencyConstraint.path, controllers: {
      sessions: 'agency/sessions',
      passwords: 'agency/passwords'
    }
    devise_scope :agency do
      get 'agency/password/sent', to: 'agency/passwords#sent', as: :new_agency_password_sent
      get 'agency/password/expired', to: 'agency/passwords#expired', as: :new_agency_password_expired
    end
    namespace :agency, path: Subdomain::AgencyConstraint.path do
      root to: 'clients#index'
      resources :clients do
        get :search, on: :collection
        get :delete_confirm, on: :member
        get :sso, on: :member
      end
      resource :profile, only: %i(edit update)
    end
  end

  # API
  namespace :api do
    namespace :v1 do
      namespace :staff do
        post :login, to: 'auth#login'
        delete :logout, to: 'auth#logout'
        resources :channels, only: [:index] do
          resources :messages, only: [:index, :create] do
            post :send_template, on: :collection
            post :send_scenario, on: :collection
          end
          get 'scenarios', on: :member
          post 'update_last_seen', on: :member
        end
        get 'emojis/:pack_id', to: 'emojis#show', as: :emojis
        resources :medias, only: [:index, :create]
        resources :templates, only: :index
      end
    end
  end
end
