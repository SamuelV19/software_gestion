Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root 'sales#index'

  resources :sales, only: [:new, :create, :show, :index] do
    member do
      get :invoice
      get :invoice_pdf
      patch :cancel
    end
  end  

  resources :reports, only: [:index] do
    collection do
      get :sales_summary
      get :export_csv
    end
  end
end
