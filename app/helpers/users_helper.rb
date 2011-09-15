module UsersHelper
  def user_avatar(user, options = {})
    options[:class] ||= "normal"
    if !user.nil? # user exists    
      if user.use_gravatar? 
        gravatar_image(user, options)
      else # don't use gravatar, check local avatars 
        avatar_image(user, options)
      end
    else # user doesn't exist
      return raw "<img src=\"/themes/#{@setting[:theme]}/images/icons/failure.png\" class=\"icon\" title=\"#{t("notice.item_not_found", :item => User.model_name.human)}\">"      
    end     
  end 

  def avatar_image(user, options = {})
      options[:title] = user.to_s
      if user.avatar.blank? ? false : File.exists?(user.avatar.path)  
        return image_tag(user.avatar.url, options)
      else # get default avatar
        return theme_image_tag("default_avatar.png", options)        
      end        
  end 
  
  def gravatar_image(object, options = {})
    email = (object.class == User) ? object.email.downcase : (object.class == String ? object : nil)
    options[:title] ||= Object.class == User ? object.to_s : nil
    return image_tag("http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5.hexdigest(email)}?d=#{URI.escape(@setting[:url] + @setting[:theme_url] + "/images/default_avatar.png")}&s=100", options)
  end  
end