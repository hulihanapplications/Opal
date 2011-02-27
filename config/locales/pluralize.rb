# All .yml & .rb files in config/locales are loaded into the i18n load path, and are generated into a gigantic hash. You can store your dictionary in either .rb or .yml form!

# This file contains all the specialized pluralization rules for iI8n.
{
  :en => { :i18n => { :plural => { :rule => lambda { |n| n == 1 ? :one : :other } } } },
  :ru => { :i18n => { :plural => { :rule => lambda { |n| n == 1 ? :one : :other } } } }
  #:ru => { :i18n => { :plural => { :rule => lambda { |n|  n % 10 == 1 && n % 100 != 11 ? :one : (2..4).include?(n % 10) && !(12..14).include?(n % 100) ? :few : n % 10 == 0 || (5..9).include?(n % 10) || (11..14).include?(n % 100) ? :many : :other } } } }
}
