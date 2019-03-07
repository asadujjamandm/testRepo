NsiWeb::Application.routes.draw do
  get "about/index"
  get "user_setting/index"
  get "user_setting/update"


  match '/signin', :to => 'auths#new'
  #match '/auths', :to => 'auths#create'
  match '/auths', :controller => 'auths', :action => 'create'
  match '/signout', :to => 'auths#destroy'

  #match '/signup', :to => 'registers#new'
  #match '/registers', :controller => 'registers', :action => 'create'
  get 'signup', :to => 'registers#new'
  post 'signup', :to =>'registers#create'

  get 'resetpassword', :to => 'forget_password#new'
  post 'resetpassword', :to => 'forget_password#create'
  match '/client/create', :controller => 'client', :action => 'create'
  match '/client/edit', :controller => 'client', :action => 'edit'
  match '/client/update', :controller => 'client', :action => 'update'
  match '/client/delete', :controller => 'client', :action => 'delete'
  match '/client/search', :controller => 'client', :action => 'search'
  match '/matter/autocomplete_list', :controller => 'matter', :action => 'autocomplete_list'

  match '/matter/create', :controller => 'matter', :action => 'create'
  match '/matter/edit', :controller => 'matter', :action => 'edit'
  match '/matter/update', :controller => 'matter', :action => 'update'
  match '/matter/delete', :controller => 'matter', :action => 'delete'
  match '/matter/search', :controller => 'matter', :action => 'search'


  match '/timecards/create', :controller => 'timecards', :action => 'create'
  match '/timecards/edit', :controller => 'timecards', :action => 'edit'
  match '/timecards/update', :controller => 'timecards', :action => 'update'
  match '/timecards/cancel', :controller => 'timecards', :action => 'cancel'
  match '/timecards/delete', :controller => 'timecards', :action => 'delete'
  match '/timecards/search', :controller => 'timecards', :action => 'search'
  match '/timecards/external_search', :controller => 'timecards', :action => 'external_search'
  match '/timecards/temporary_matter', :controller => 'timecards', :action => 'temporary_matter'
  match '/timecards/autocomplete_list', :controller => 'timecards', :action => 'autocomplete_list'
  match '/timecards/timecard_list', :controller => 'timecards', :action => 'timecard_list'
  match '/timecards/matter_bill_status', :controller => 'timecards', :action => 'matter_bill_status'
  match '/timecards/calendar_view', :controller => 'timecards', :action => 'calendar_view'

  match '/syncs/sync_timecard', :controller => 'syncs', :action => 'sync_timecard'
  match '/syncs/sync_matter', :controller => 'syncs', :action => 'sync_matter'
  match '/syncs/sync_client', :controller => 'syncs', :action => 'sync_client'
  match '/syncs/sync_timekeeper', :controller => 'syncs', :action => 'sync_timekeeper'
  match '/syncs/sync_all', :controller => 'syncs', :action => 'sync_all'
  match '/syncs/index', :controller => 'syncs', :action => 'index'

  match '/timecard_reports/last_four_weeks', :controller => 'timecard_reports', :action => 'last_four_weeks'
  match '/timecard_reports/month_to_date', :controller => 'timecard_reports', :action => 'month_to_date'
  match '/timecard_reports/year_to_date', :controller => 'timecard_reports', :action => 'year_to_date'
  match '/timecard_reports/search', :controller => 'timecard_reports', :action => 'search'
  match '/timecard_reports/view_pdf', :controller => 'timecard_reports', :action => 'view_pdf'
  match '/timecard_reports/week_report', :controller => 'timecard_reports', :action => 'week_report'
  match '/timecard_reports/export_timecard_txt', :controller => 'timecard_reports', :action => 'export_timecard_txt'
  match '/timecard_reports/export_timecard_xml', :controller => 'timecard_reports', :action => 'export_timecard_xml'
  match '/timecard_reports/external_timecards_search', :controller => 'timecard_reports', :action => 'external_timecards_search'
  match '/timecard_reports/export_to_quickbooks', :controller => 'timecard_reports', :action => 'export_to_quickbooks'
  match '/timecard_reports/qb_authenticate', :controller => 'timecard_reports', :action => 'qb_authenticate'
  match '/timecard_reports/oauth_callback', :controller => 'timecard_reports', :action => 'oauth_callback'
  match '/timecard_reports/create_timeactivity', :controller => 'timecard_reports', :action => 'create_timeactivity'
  match '/timecard_reports/autocomplete_list', :controller => 'timecard_reports', :action => 'autocomplete_list'
=begin
  resources :timecard_reports do
    collection do
      get :authenticate
      get :oauth_callback
    end
  end
=end
  match '/users/create', :controller => 'users', :action => 'create'
  match '/users/edit', :controller => 'users', :action => 'edit'
  match '/users/update', :controller => 'users', :action => 'update'
  match '/users/cancel', :controller => 'users', :action => 'cancel'
  match '/users/delete', :controller => 'users', :action => 'delete'
  match '/users/search', :controller => 'users', :action => 'search'
  match '/users/external_search', :controller => 'users', :action => 'external_search'
  match '/users/show_user_roles', :controller => 'users', :action => 'show_user_roles'
  match '/users/autocomplete_list', :controller => 'users', :action => 'autocomplete_list'

  match '/roles/create', :controller => 'roles', :action => 'create'
  match '/roles/edit', :controller => 'roles', :action => 'edit'
  match '/roles/update', :controller => 'roles', :action => 'update'
  match '/roles/cancel', :controller => 'roles', :action => 'cancel'
  match '/roles/delete', :controller => 'roles', :action => 'delete'
  match '/roles/show_role_permissions', :controller => 'roles', :action => 'show_role_permissions'

  match '/change_password/update', :controller => 'change_password', :action => 'update'
  match '/user_setting/update', :controller => 'user_setting', :action => 'update'

  match '/locality/update', :controller => 'locality', :action => 'update'
  match '/locality/reset', :controller => 'locality', :action => 'reset'

  match '/homes', :controller => 'homes', :action => 'index'
  match '/about', :controller => 'about', :action => 'index'
  match '/walkthroughs', :controller => 'walkthroughs', :action => 'index'
  match '/videos', :controller => 'walkthroughs', :action => 'index'
  match '/blackberry_walkthrough', :controller => 'blackberry_walkthrough', :action => 'index'
  match '/iphone_walkthrough', :controller => 'iphone_walkthrough', :action => 'index'
  match '/android_walkthrough', :controller => 'android_walkthrough', :action => 'index'
  match '/farm_setting/update', :controller => 'farm_setting', :action => 'update'

  match '/timekeeper/create', :controller => 'timekeeper', :action => 'create'
  match '/timekeeper/edit', :controller => 'timekeeper', :action => 'edit'
  match '/timekeeper/delete', :controller => 'timekeeper', :action => 'delete'
  match '/timekeeper/update', :controller => 'timekeeper', :action => 'update'
  match '/timekeeper/cancel', :controller => 'timekeeper', :action => 'cancel'
  match '/timekeeper/search', :controller => 'timekeeper', :action => 'search'

  match '/activitycodes/create', :controller => 'activitycodes', :action => 'create'
  match '/activitycodes/edit', :controller => 'activitycodes', :action => 'edit'
  match '/activitycodes/delete', :controller => 'activitycodes', :action => 'delete'
  match '/activitycodes/update', :controller => 'activitycodes', :action => 'update'
  match '/activitycodes/cancel', :controller => 'activitycodes', :action => 'cancel'
  match '/activitycodes/search', :controller => 'activitycodes', :action => 'search'

  #match '/registered_users/create_farm', :controller => 'registered_users', :action => 'create_farm'
  post 'create_farm', :to =>'registered_users#create_farm'
  match '/registered_users/cancel', :controller => 'registered_users', :action => 'cancel'
  match '/registered_users/delete', :controller => 'registered_users', :action => 'delete'
  match '/registered_users/index', :controller => 'registered_users', :action => 'index'
  match '/registered_users/confirm', :controller => 'registered_users', :action => 'confirm'
  #post 'confirm', :to => 'registered_users#confirm'
  match '/registered_users/autocomplete_list', :controller => 'registered_users', :action => 'autocomplete_list'

  #get 'subscription', :to => 'registers#new'
  #post 'subscription', :to =>'registers#create'
  match 'subscriptions/create', :controller =>'subscriptions', :action => 'create'
  match 'subscriptions/confirm', :controller =>'subscriptions', :action => 'confirm'
  match 'subscriptions/cancel', :controller =>'subscriptions', :action => 'cancel'
  match 'subscriptions/notify', :controller =>'subscriptions', :action => 'notify'
  match 'subscriptions/notice/:model_id', :controller =>'subscriptions', :action => 'notice', :as => 'notice'
  match 'subscriptions/:id', :controller =>'subscriptions', :action => 'show'
  #post "/hook" => "subscriptions#hook"
  match "/hook", :controller => 'subscriptions', :action =>'hook'
  #post "/:id" => 'subscriptions#show'
  #match '/site_index', :controller => 'site_index', :action => 'index'
  #match '/products', :controller => 'products', :action => 'index'
  #match '/partners', :controller => 'partners', :action => 'index'
  #match '/about_us', :controller => 'about_us', :action => 'index'
  #match '/contact_us', :controller => 'contact_us', :action => 'index'
  #match '/wiptime_web', :controller => 'wiptime_web', :action => 'index'

  resources :homes
  resources :timecards
  resources :syncs
  resources :reports
  resources :settings
  resources :timecard_reports
  resources :user_roles
  resources :users
  resources :roles
  resources :change_password
  resources :user_setting
  resources :locality
  resources :about
  resources :walkthroughs
  resources :blackberry_walkthrough
  resources :iphone_walkthrough
  resources :android_walkthrough
  resources :farm_setting
  resources :client
  resources :matter
  resources :timekeeper
  resources :activitycodes
  resources :registers
  resources :registered_users
  resources :subscriptions
  #resources :site_index
  #resources :products
  #resources :partners
  #resources :about_us
  #resources :contact_us
  #resources :wiptime_web


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
  root :to => "auths#new"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  match '*a', :to => 'errors#routing'

end
