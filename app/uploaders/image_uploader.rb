# encoding: utf-8
class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or ImageScience support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"    
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  
  process :monochrome, :if => :monochrome?
  process :sepia, :if => :sepia?
  process :rotate_90_cw, :if => :rotate_90_cw?
  process :rotate_90_ccw, :if => :rotate_90_ccw?
  process :rotate_180, :if => :rotate_180?
  process :negate, :if => :negate?
  process :polaroid, :if => :polaroid?
  process :resize, :if => :resize?
  process :stamp, :if => :stamp?
  process :watermark, :if => :watermark?  
 
  # Create different versions of your uploaded files:
  version :thumb do
     #process :scale => [125, 50]
     process :resize_to_fill => [180, 125] 
     #process :resize_to_fill => [Setting.global_settings[:plugin_image][:item_thumbnail_width].to_i, Setting.global_settings[:plugin_image][:item_thumbnail_height].to_i]     
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  
  def monochrome?(*args)
    model.effects[:monochrome] == "1" if model.effects
  end

  def monochrome
    manipulate! do |img| 
      img.quantize(256, Magick::GRAYColorspace)
    end 
  end

  def sepia?(*args)
    model.effects[:sepia] == "1" if model.effects
  end

  def sepia
    manipulate! do |img| 
      new_img = img.quantize(256, Magick::GRAYColorspace)
      new_img.colorize(0.30, 0.30, 0.30, '#cc9933')      
    end 
  end
  
  def rotate_90_cw?(*args)
    model.effects[:rotate_90_cw] == "1" if model.effects
  end

  def rotate_90_cw
    manipulate! do |img| 
      img.rotate(90)    
    end 
  end  

  def rotate_90_ccw?(*args)
    model.effects[:rotate_90_ccw] == "1" if model.effects
  end

  def rotate_90_ccw
    manipulate! do |img| 
      img.rotate!(-90) 
    end 
  end  

  def rotate_180?(*args)
    model.effects[:rotate_180] == "1" if model.effects
  end

  def rotate_180
    manipulate! do |img| 
      img.rotate!(180) 
    end 
  end  

  def resize?(*args)
    model.effects[:resize] == "1" if model.effects
  end

  def resize
    manipulate! do |img|
      width = Setting.global_settings[:plugin_image][:item_image_width].to_i
      height = Setting.global_settings[:plugin_image][:item_image_height].to_i      
      img.crop_resized!(width, height)  
    end 
  end

  def negate?(*args)
    model.effects[:negate] == "1" if model.effects
  end

  def negate
    manipulate! do |img| 
      img.negate
    end 
  end   

  def polaroid?(*args)
    model.effects[:polaroid] == "1" if model.effects
  end

  def polaroid
    manipulate! do |img| 
      img.border!(10, 10, "#f0f0ff")    
      # Bend the image
      img.background_color = "none"    
      amplitude = img.columns * 0.01        # vary according to taste
      wavelength = img.rows  * 2    
      img.rotate!(90)
      img = img.wave(amplitude, wavelength)
      img.rotate!(-90)    
      # Make the shadow
      shadow = img.flop
      shadow = shadow.colorize(1, 1, 1, "gray75")     # shadow color can vary to taste
      shadow.background_color = "white"       # was "none"
      shadow.border!(10, 10, "white")
      shadow = shadow.blur_image(0, 3)        # shadow blurriness can vary according to taste      
      # Composite image over shadow. The y-axis adjustment can vary according to taste.
      img = shadow.composite(img, -amplitude/2, 5, Magick::OverCompositeOp)      
      img.rotate!(-5)        
    end 
  end

  def watermark?(*args)
    model.effects[:watermark] == "1" if model.effects
  end

  def watermark
    manipulate! do |img| 
      watermark_path = File.join(Setting.global_settings[:theme_dir], "images", "watermark.png")
      if File.exists?(watermark_path) # use watermark image
        watermark_image = Magick::Image.read(watermark_path).first 
        img.composite!(watermark_image, Magick::CenterGravity, Magick::OverCompositeOp)     
      else # no watermark image found, generate one from text
        watermark_image = Magick::Image.new(300, 50) do # since Image.new returns an actual image, you must initialize image properties(like bg color, etc. in the initialization block of the object) 
          self.background_color = "transparent" # uncomment for Method 2 & 3
        end
        gc = Magick::Draw.new
        watermark_text = Setting.global_settings[:title]
        gc.annotate(watermark_image, 0, 0, 0, 0, watermark_text) do 
          gc.gravity = Magick::CenterGravity
          gc.pointsize = 32
          gc.font_family = "Helvetica"
          gc.stroke = "none"
          gc.fill = "black"                     
        end
           
        img.watermark(watermark_image, 0.15, 0, Magick::CenterGravity)
      end              
    end  
  end  

  def stamp?(*args)
    model.effects[:stamp] == "1" if model.effects
  end

  def stamp
    manipulate! do |img|
     stamp_path = File.join(Setting.global_settings[:theme_dir], "images", "stamp.png")
     if File.exists?(stamp_path) # use existing stamp image
       stamp_image = Magick::Image.read(stamp_path).first 
       img.composite!(stamp_image, Magick::SouthEastGravity, Magick::OverCompositeOp)  # Other Gravities: SouthEastGravity, NorthGravity(centered), etc.    
     else # no existing stamp image, generate one from text
       logger.error("No Stamp Found: #{stamp_path}")
     end       
    end 
  end      
end
