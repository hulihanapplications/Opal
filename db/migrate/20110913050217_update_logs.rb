class UpdateLogs < ActiveRecord::Migration
  def change
    add_column :logs, :ip, :string
    add_column :logs, :archived_target, :string

    # Migrate Item Logs to Polymorphic Log 
    for log in Log.where("item_id is not ?", nil)
      log.update_attributes(:target_type => "Item", :target_id => log.item_id)
      say("#{Log.model_name.human} #{log.id} #{I18n.t("single.updated", :default => "Updated")}", true) 
    end     
  end 
end
