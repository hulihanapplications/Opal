class ResaveObjectsToGenerateSlugs < ActiveRecord::Migration
  def up
    # This migration is needed for users who upgrade Opal from v0.8.1 to v0.8.2
    # Existing objects need to have slugs for Friendly URLs 
    # Resaving existing objects (without any changes) will generate slugs for them
    Category.find_each(&:save)
    Item.find_each(&:save)
    Page.find_each(&:save)
    User.find_each(&:save)
  end
end
