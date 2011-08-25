Opal::Application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.

  @setting = Setting.global_settings

  #map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  #match '/simple_captcha/:action', :controller => 'simple_captcha'

  # Set up default
  root :to => "browse#index"

  match '/tag/:tag(/:category_id)' => 'items#tag', :as => :tag
  match '/download/:id', :controller => "plugin_files", :action => "download"
  match '/verify/:id/:code', :controller => "user", :action => "verify"
  match '/page/:id', :controller => "pages", :action => "page"

  if (Setting.get_setting('locale').to_s == 'en')
    match "/#{Item.model_name.human(:count => :other).downcase}(/:action(/:id(.:format)))", :controller => "items" # use plural item name in url for anything in the items controller 
  elsif (Setting.get_setting('locale').to_s == 'ru')
    match "/#{Russian.translit(Item.model_name.human(:count => :other)).downcase}(/:action(/:id(.:format))", :controller => "items" # Russian variant uses transliteration to avoid encoding troubles 
  end

  match '/blog/:year(/:month(/:day))',
               :controller => 'blog',
               :action     => 'archive',
               :month => nil, :day => nil,
               :constraints  => {:year => /\d{4}/, :month => /\d{1,2}/,:day => /\d{1,2}/},
               :as => :blog_archive


  
  # Resources

  # See how all your routes lay out with "rake routes"
   
  # Simple Captcha
  match '/simple_captcha/:id', :to => 'simple_captcha#show', :as => :simple_captcha

  # User Authentication
  match 'login', :controller => "user_sessions", :action => "new"
  match 'logout', :controller => "user_sessions", :action => "destroy"
  resources :user_sessions
  
  resources :users
  resources :plugin_videos
  
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'

  
end


