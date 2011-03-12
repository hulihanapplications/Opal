# All .yml & .rb files in config/locales are loaded into the i18n load path, and are generated into a gigantic hash. You can store your dictionary in either .rb or .yml form!

# This file contains all the specialized pluralization rules for iI8n.
{
  :en => { :i18n => { :plural => { :rule => lambda { |n| n == 1 ? :one : :other } } } }
}
