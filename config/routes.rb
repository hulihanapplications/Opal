Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes"

  @setting = Setting.global_settings

  #map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  #match '/simple_captcha/:action', :controller => 'simple_captcha'

  # Set up default
  root :to => "browse#index"
  match '/tag/:tag(/:category_id)' => 'items#tag', :as => :tag
  match '/download/:record_type/:record_id', :controller => "plugin_files", :action => "download", :as => "download"
  match '/verify/:id/:code', :controller => "user", :action => "verify"
  match '/page/:id', :controller => "pages", :action => "page"
  match 'account', :controller => "user", :action => "index", :as => "user_home"
  match 'admin', :controller => "admin", :action => "index"


  match 'feed' => 'items#feed', :as => "feed", :defaults => { :format => 'atom' }
  # Blog
  match "blog" => "blog#index"
  match '/blog/:year(/:month(/:day))',
               :controller => 'blog',
               :action     => 'archive',
               :month => nil, :day => nil,
               :constraints  => {:year => /\d{4}/, :month => /\d{1,2}/,:day => /\d{1,2}/},
               :as => :blog_archive

  match 'blog/feed' => 'blog#feed', :as => "blog_feed", :defaults => { :format => 'atom' }


#  if (Setting.get_setting('locale').to_s == 'en')
    match "/#{Item.model_name.human(:count => :other).downcase}(/:action(/:id(.:format)))", :controller => "items" # use plural item name in url for anything in the items controller 
#  elsif (Setting.get_setting('locale').to_s == 'ru')
#    match "/#{Russian.translit(Item.model_name.human(:count => :other)).downcase}(/:action(/:id(.:format))", :controller => "items" # Russian variant uses transliteration to avoid encoding troubles 
#  end

   
  # Simple Captcha
  match '/simple_captcha/:id', :to => 'simple_captcha#show', :as => :simple_captcha

  # Resources  
  resources :user_sessions
  # User Authentication
  match 'login', :controller => "user_sessions", :action => "new"
  match 'logout', :controller => "user_sessions", :action => "destroy"

  
  resources :users do 
    get "verification_required", :on => :collection
  end

  resources :authentications do
    get "confirm", :on => :collection
    get "forget", :on => :collection
  end
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'
  
  resources :plugin_videos do 
    get :delete, :on => :collection 
  end
  
  resources :logs do
    get "for_me", :on => :collection
    get "for_item", :on => :collection
    get "for_user", :on => :collection            
  end

  resources :pages do
    collection do
      get "send_contact_us"
      get "update_order"
      get "delete"
    end
    get "view", :on => :member
  end  
  
  resources :settings do 
    collection do
      get "test_email"
      get "themes"
      get "install_theme"
      get "delete_theme"
      get "change_logo"
      get "delete_logo"      
      get "new_change_logo"
      get "update_settings"
      get "new_theme_install"
    end 
  end 
  
  # Create cms-like page urls. 
  #   example.com/my-page
  # This takes low priority in the case that a page title conflicts with a controller route.
  # You can generate this url with the `page_root_path` helper method.
  Page.public.all.each do |page|
    match page.to_param, :controller => 'pages', :action => 'show', :id => page.to_param
  end if Page.table_exists? 

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end


