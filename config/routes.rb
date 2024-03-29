DecaturDigest::Application.routes.draw do
  
  get "/organizations" => "organizations#index", :as => :organizations
  match "/organization/new" => "organizations#new", :as => :new_organization
  get "/organization/:id" => "organizations#show", :as => :organization
  match "/organization/edit/:id" => "organizations#edit", :as => :edit_organization
  delete "/organization/delete/:id" => "organizations#delete", :as => :delete_organization

  get "workflow/my", :as => :my_workflows
  get "workflow/managed", :as => :managed_workflows
  match "workflow/new", :as => :new_workflow
  match "/workflow/edit/:id" => "workflow#edit", :as => :edit_workflow
  match "/workflow/view/:id" => "workflow#view", :as => :workflow
  delete "/workflow/delete/:id" => "workflow#delete", :as => :delete_workflow
  match "/workflow/lots" => "workflow#add_lots", :as => :add_lots_to_workflow
  get 'workflow/add/:workflow/:lot' => "workflow#add", :as => :add_to_workflow
  get 'workflow/remove/:workflow/:lot' => "workflow#remove", :as => :remove_from_workflow

  match '/appeal' => 'lots#appeal', :as => :appeal
  get '/appeal-reports' => 'lots#appeal_reports', :as => :appeal_reports
  match '/refine-appeal' => 'lots#refine_appeal', :as => :refine_appeal
  get '/similar-lots-ajax' => 'lots#ajax_similar_lots', :as => :ajax_similar_lots
  get '/appeal-flagged-properties' => 'lots#appeal_flagged_properties', :as => :appeal_flagged_properties

  root :to => "application#index"
    
  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"},
                     controllers: {omniauth_callbacks: "omniauth_callbacks"}

  resources :lots do
    collection { match :search, to: 'lots#index' }
    member { post :vote }
  end
  resources :users
  resources :map

  get '/dev-login' => 'users#login_dev', :as => :development_login
  
  get "static_pages/about"
  get "static_pages/contact"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
