ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "browse"

  @setting = Setting.global_settings

  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
 
  # Set up default
  map.connect '/', :controller => "browse"
  map.connect '/browse', :controller => "browse"

  map.connect '/tag/:tag', :controller => "items", :action => "tag"
  map.connect '/download/:id', :controller => "plugin_files", :action => "download"
  map.connect '/verify/:id/:code', :controller => "user", :action => "verify"
  map.connect '/page/:id', :controller => "pages", :action => "page"

  map.connect "/#{@setting[:item_name_plural]}/:action/:id", :controller => "items" # use plural item name in url for anything in the items controller 
  
  map.connect '/blog/:year/:month/:day',
               :controller => 'blog',
               :action     => 'archive',
               :month => nil, :day => nil,
               :requirements => {:year => /\d{4}/, :month => /\d{1,2}/,:day => /\d{1,2}/ }


  #map.namespace :user do |user| 
  # user.resources :item_objects
  # user.namespace :item_objects do |item_objects|
  #       # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #       item_objects.resources :reviews
  # end
  #end


  #Rails.plugins.each do |plugin|
  #  map.from_plugin plugin.name.to_sym
  #end
  # Load Plugin Routes
  Dir["#{RAILS_ROOT}/vendor/plugins/*"].each do |plugin| 
    if File.exists?("#{plugin}/routes.rb") 
      File.open("#{plugin}/routes.rb").each do |line|
        eval "#{line}" 
      end
    end
  end
  
  #Dir["#{RAILS_ROOT}/vendor/plugins/*"].each do |plugin_dir|
    #map.from_plugin(File.basename(plugin_dir))
  #end  


  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end


