require "opal/active_record"
require "opal/action_view"
require "opal/action_controller"
require "opal/acts_as_opal_plugin"
require "opal/version"

ActiveRecord::Base.send :include, Opal::ActiveRecord::Base::InstanceMethods
ActiveRecord::Base.send :extend, Opal::ActiveRecord::Base::ClassMethods

ActionView::Base.send :include, Opal::ActionView::Base
ActionView::Base.send :include, Opal::ActionView::Helpers::FormHelper

ActionController::Base.send :include, Opal::ActionController::Base


module Opal
  def self.locales_dir
    File.join(Rails.root.to_s, "config", "locales") 
  end
  
  def self.current_locale_path # path to current locale file 
    File.join(Rails.root.to_s, "config", "locales", I18n.locale.to_s +  ".yml") 
  end  
  
  def self.current_locale_hash # hash of current FULL locale, used to rewrite translation file  
    {I18n.locale.to_sym => I18n.t(".")}
  end 
end