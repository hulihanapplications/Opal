class PolymorphicPlugins < ActiveRecord::Migration
  def klasses 
    [PluginComment, PluginDescription, PluginDiscussion, PluginFeatureValue, PluginFile, PluginImage, PluginLink, PluginTag, PluginVideo]
  end 
  
  def polymorphize(klass)
    add_column klass.table_name.to_sym, :record_type, :string
    add_column klass.table_name.to_sym, :record_id, :integer        
    klass.reset_column_information

    klass.all do |r|
      r.record = Item.find(r.item_id)
      say("#{klass.model_name.human} #{r.id} #{I18n.t("single.updated", :default => "Updated")}", true) if r.save 
    end

    remove_column klass.table_name.to_sym, :item_id            
  end
  
  def unpolymorphize(klass)
    add_column klass.table_name.to_sym, :item_id, :integer
    klass.reset_column_information

    klass.where(:record_type => "Item").all do |r|
      r.item_id = r.record
      say("#{klass.model_name.human} #{r.id} #{I18n.t("single.updated", :default => "Updated")}", true) if r.save
    end

    remove_column klass.table_name.to_sym, :record_type
    remove_column klass.table_name.to_sym, :record_id    
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
