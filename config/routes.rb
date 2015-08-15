Rails.application.routes.draw do
  get '/:locale' => 'home#index', :as => 'locale_root'
  scope "(:locale)", locale: /en|de/ do
    post 'users' => 'users#create'
    devise_for :users
    get 'home/index'
    resources :users do
      get 'time_entries/content/' => "time_entries#day_content"
      resources :time_entries
      resources :employments
      resources :leave_days
      get 'reports/current/' => 'reports#current'
      get 'reports/current/(:year/:month)' => 'reports#current'
      get 'reports/content/(:year)/(:month)' => 'reports#content'
      resources :reports
    end
    resources :public_holidays
    post 'time_tracking/start' => 'time_tracking#start'
    post 'time_tracking/stop' => 'time_tracking#stop'

    get 'statistics/index'
    get 'statistics/working_hours'
    get 'statistics/working_hours/content/' => "statistics#working_hours_content"
    get 'statistics/leave_days'
    get 'statistics/leave_days/content/' => "statistics#leave_days_content"

  end
  # ====== API Routes ======
  post 'api/v1/login' => 'api/v1/api_login#login'
  post 'api/v1/status/start' => 'api/v1/api_status#start'
  post 'api/v1/status/stop' => 'api/v1/api_status#stop'
  get 'api/v1/status' => 'api/v1/api_status#status'
  get 'api/v1/calendars/leave_days' => "api/v1/api_calendars#leave_days"
  get 'api/v1/calendars/public_holidays' => "api/v1/api_calendars#public_holidays"
  # ====== Calendar stuff =====

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root "home#index"
end
