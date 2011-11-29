module PluginsHelper
  def link_to_plugin_record(plugin_record, options = {})
    link_to plugin_record.to_s, {:action => :view, :controller => plugin_record.record.class.controller_name, :id => plugin_record.record_id, :anchor => plugin_record.class.model_name.human(:count => :other)}, options
  end
end