Qbpos01::Application.routes.draw do
  get "pages/home"

  get "pages/contact"
  
  get "pages/intuitstart"
  
  #######################
  get "company/show"

  post  "login" => "user_sessions#create"
  match "login" => "user_sessions#new", :as => :login
  match "logout" => "user_sessions#destroy", :as => :logout

  post  "signup" => "users#create"
  match "signup" => "users#new", :as => :signup
  match "account" => "users#show", :as => :account
  match "account/disconnect" => "users#cancel", :as => :users_cancel

  match "intuit/connect" => "intuit#connect", :as => :intuit_connect
  match "intuit/callback" => "intuit#callback", :as => :intuit_callback
  match "intuit/disconnect" => "intuit#disconnect", :as => :intuit_disconnect
  match "intuit/proxy" => "intuit#proxy", :as => :intuit_menu_proxy
  match "intuit/config" => "intuit#oauth_config"
  match "intuit/status" => "intuit#oauth_status"


  match "companies" => "company#index"  
  match "company/:id" => "company#show", :as => :company
  match "company/:id/proxy" => "company#proxy", :as => :company_proxy
  match "company/:id/customers" => "company#customers", :as => :company_customers
  match "company/:id/disconnect" => "company#disconnect", :as => :company_disconnect
  match "company/:id/reconnect" => "company#reconnect", :as => :company_reconnect
  
  
  #######################

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
