class PolymorphicPlugins < ActiveRecord::Migration
  # Clear Models with Carrierwave Mounts for this migration, since their normal models depend on columns that don't exist yet. 
  class PluginFile < ActiveRecord::Base; end
  class PluginImage < ActiveRecord::Base; end
  class PluginVideo < ActiveRecord::Base; end

  def klasses 
    [PluginComment, PluginDescription, PluginDiscussion, PluginFeatureValue, PluginFile, PluginImage, PluginLink, PluginReview, PluginTag, PluginVideo]
  end 
  
  def polymorphize(klass)
    add_column klass.table_name.to_sym, :record_type, :string
    add_column klass.table_name.to_sym, :record_id, :integer        
    klass.reset_column_information

    klass.all.each do |r|
      item = Item.find(r.item_id)
      r.record_type, r.record_id = item.class.name, item.id
      say("#{klass.model_name.human} #{r.id} #{I18n.t("single.updated", :default => "Updated")}", true) if r.save
    end

    remove_column klass.table_name.to_sym, :item_id
    klass.reset_column_information                
  end
  
  def unpolymorphize(klass)
    add_column klass.table_name.to_sym, :item_id, :integer
    klass.reset_column_information

    klass.where(:record_type => "Item").all.each do |r|
      r.item_id = r.record_id
      say("#{klass.model_name.human} #{r.id} #{I18n.t("single.updated", :default => "Updated")}", true) if r.save
    end

    remove_column klass.table_name.to_sym, :record_type
    remove_column klass.table_name.to_sym, :record_id  
    klass.reset_column_information  
  end
  
  def up
    klasses.each do |klass|
      polymorphize(klass)
    end                                        
  end

  def down
    klasses.each do |klass|
      unpolymorphize(klass)
    end       
  end
end
