# Switch YAML Parser
require 'yaml'
if defined?(YAML::ENGINE)
	YAML::ENGINE.yamler = 'syck'
end