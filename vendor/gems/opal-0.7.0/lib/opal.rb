require "opal/active_record"
require "opal/action_view"
require "opal/action_controller"
require "opal/plugin_support"


ActiveRecord::Base.send :include, Opal::ActiveRecord::Base::InstanceMethods
ActiveRecord::Base.send :extend, Opal::ActiveRecord::Base::ClassMethods

ActionView::Base.send :include, Opal::ActionView::Base
ActionView::Base.send :include, Opal::ActionView::Helpers::FormHelper

ActionController::Base.send :include, Opal::ActionController::Base
