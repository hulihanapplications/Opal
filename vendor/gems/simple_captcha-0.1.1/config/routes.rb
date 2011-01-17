Rails.application.routes.draw do
  match '/simple_captcha/:id', :to => 'simple_captcha#show', :as => :simple_captcha
end
