Rails.application.routes.draw do
  get "teachers/index"
  get "teachers/destroy"
  resources :classrooms, only: [ :index, :show ]

  resources :classrooms do
    collection do
      get "by_grade/:grade", to: "classrooms#by_grade", as: "by_grade"
    end
    member do
      get :grading
      get :grade_level
    end
    resources :students, only: [ :index, :show ]
  end

  # Attendances Routes
  resources :attendances do
    collection do
      get "scan_qr", to: "attendances#scan_qr", as: "scan_qr"
      post "checkin", to: "attendances#checkin"
    end
  end
  resources :attendances, only: [ :create ] do
    get "/check_if_checked_in", to: "attendances#check_if_checked_in"
  end

  # Profile
  get "/profile", to: "students#profile"

  # Students
  resources :students do
    collection do
      post "mark_attendance"
    end
  end

  # Other Routes
  get "home/index"
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[ new create ]
  resources :users, only: %i[ index ] do
    member do
      patch :approve
    end
  end

  get "login", to: "sessions#new", as: "login"
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Additional Student Actions
  resources :students do
    member do
      patch :toggle_status
      patch :archive
      patch :activate
    end
    collection do
      get :manage
    end
  end

  get "classrooms/:id/grades/:grade", to: "classrooms#grading", as: :grading_by_grade
  get "grades/:grade", to: "classrooms#by_grade", as: :grade

  # Teachers & Users
  resources :teachers, only: [ :index, :destroy ]
  resources :users, only: [ :index, :destroy ]
end
