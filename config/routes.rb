RubyApi::Application.routes.draw do
  root to: "top#index"

  resources :paragraphs, only: [:update]

  lang = /\w\w(-\w\w)?/
  ver = /\d.\d.\d/
  lib = /[a-z].*/

  get ":lang/:version/:library/:module/:::name" => "view#show_constant"       , :lang => lang, :version => ver, :library => lib
  get ":lang/:version/:library/:module/.:name"  => "view#show_class_method"   , :lang => lang, :version => ver, :library => lib
  get ":lang/:version/:library/:module/:name"   => "view#show_instance_method", :lang => lang, :version => ver, :library => lib
  get ":lang/:version/:library/:module"         => "view#show_module"         , :lang => lang, :version => ver, :library => lib
  get ":lang/:version/:library"                 => "view#show_library"        , :lang => lang, :version => ver, :library => lib

  get ":lang/:version/:module/:::name" => "view#show_constant"       , :lang => lang, :version => ver, :library => "_builtin"
  get ":lang/:version/:module/.:name"  => "view#show_class_method"   , :lang => lang, :version => ver, :library => "_builtin"
  get ":lang/:version/:module/:name"   => "view#show_instance_method", :lang => lang, :version => ver, :library => "_builtin"
  get ":lang/:version/:module"         => "view#show_module"         , :lang => lang, :version => ver, :library => "_builtin"

  get ":lang/:version" => "view#show_language_top", :lang => lang, :version => ver

  get ":lang" => redirect("/%{lang}/1.9.3"), :lang => lang

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
