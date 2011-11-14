class Uploader #< ActiveRecord::Base
  # This class handles file uploads, storage, and other options(zip extraction, extension validation, etc.)
  
  def self.file_from_url_or_local(options = {}) # pass in a local source of a file and a url for a net file, return one standardized File object.    
    options[:local]   ||= nil # file uploaded locally
    options[:url]     ||= nil   # file from a url

    options[:url] = nil if (!options[:local].blank? && !options[:url].blank?) # if they did both
    if !options[:local].blank? # use locally uploaded file  
      return options[:local]       
    elsif !options[:url].blank? # use file from url
      return Uploader.file_from_url(options[:url]) # return file from url
    else # nothing 
      return false
    end
  end 

  def self.file_from_url(url) # get a file from a particular url
    require "net/http"
    require "open-uri"    
    
    url_file = open(url) # Open the file from net
    filename = Uploader.clean_filename(File.basename(url)) # filename of url file    
    tmp_path = File.join(Dir::tmpdir, "opal") # location of the tmp folder     
    FileUtils.mkdir_p(tmp_path) if !File.exists?(tmp_path) # create the tmp folder if it doesn't exist    
    file = open(tmp_path + "/" + filename, "wb") # open up the new file, binary style
    file.write(url_file.read) # copy the file from     
    if file # temp file got copied successfully.
      file.close # close tmp
      file = open(tmp_path + "/" + filename, "rb") # reopen the temp file, load into memory   
    end    
    return file
  end

  def self.cleanup # clean up any leftovers(tmp files, etc.)
    
  end
 
  def self.check_file_extension(options = {}) # check a filename for a particular extension.
    options[:filename] ||= nil
    options[:extensions] ||= nil # this can be a string(comma delimited, with spaces, ie: ".png, .jpg") or regexp(ie: /.png|.jpg$/)
    
    if options[:extensions].class == String # if a string was entered
      options[:extensions] = Regexp.new(options[:extensions].split(", ").join("|") + "$") #  replace commas with Regexp | operator(OR), tack on $ to look at string end, then convert string to Regexp         
    end
  
    if options[:filename] && options[:extensions]
     return options[:extensions].match(options[:filename])
    else # no filename or extensions were entered
      return nil
    end
  end 

  def self.get_zip_contents(path_to_zipfile) # get the contents of a zip file
    require "zip/zip"
    require "zip/zipfilesystem"
    zipfile = ::Zip::ZipFile.open(path_to_zipfile)
    
    entry_array = Array.new # store entries in a array of strings
    for entry in zipfile
          entry_array << entry.name
    end    
    return entry_array
  end
  
  def self.extract_zip_to_tmp(path_to_zipfile) # extract a zip file into a temp directory, return directory path.
    require "zip/zip"
    require "zip/zipfilesystem"  
        
    tmp_path = File.join(Dir::tmpdir, "opal") # location of the tmp folder     
    zip_tmp_dir = File.join(tmp_path, "unzipped") # path to 'unzipped' folder, that contains all unzipped files & folders 
    extract_dir = File.join(zip_tmp_dir, File.basename(path_to_zipfile, ".zip")) # path to new folder that will contain extracted zip files
    FileUtils.rm_rf(extract_dir) if File.exists?(extract_dir)# delete the extraction dir if exists 
    FileUtils.mkdir_p(extract_dir) if !File.exists?(extract_dir)# make directory
 
    zf = ::Zip::ZipFile.open(path_to_zipfile)
    zf.each do |entry|
      entry_path = File.join(extract_dir, entry.name)
      FileUtils.mkdir_p(File.dirname(entry_path))
      zf.extract(entry, entry_path) unless File.exist?(entry_path)
    end
    
    return extract_dir # return the path to folder containing extracted files
    #return zf # return the ZipFile for entry searchess    
  end
  
  def self.clean_filename(filename) # clean filenames of any invalid chars
    @bad_chars = ['&', '\+', '%', '!', ' ', '/'] #string of bad characters
    for char in @bad_chars
     filename = filename.gsub(/#{char}/, "_") # replace the bad chars with good ones!
    end
    return filename 
  end 
  
  def self.generate_image(options = {})
     require "RMagick"
     
     @setting = Setting.global_settings # set global settings
     @plugin = Plugin.find_by_name("Image")
      
     
     # Set Defaults 
     options[:image]              ||= nil # rmagick image object
     options[:generate_thumbnail]  =  true if options[:generate_thumbnail].nil? # generate thumbnail? 
     options[:path]               ||= nil # file location for normal image
     options[:thumbnail_path]     ||= nil # file location for thumbnail
     #options[:filename]          ||= nil 
     options[:effects]            ||= Hash.new # effects hash 
     options[:resize_image]       = @plugin.get_setting_bool("resize_item_images") if options[:resize_image].nil?  # resize image?
     options[:image_width]        ||= @plugin.get_setting("item_image_width").to_i        ||= 500 # resized image width 
     options[:image_height]       ||= @plugin.get_setting("item_image_height").to_i   ||= 500 # resized image height 
     options[:thumbnail_width]    ||= @plugin.get_setting("item_thumbnail_width").to_i    ||= 100 # thumbnail width
     options[:thumbnail_height]   ||= @plugin.get_setting("item_thumbnail_height").to_i   ||= 100 # thumbnail height 
   
    #use wb+ or wb to transfer as binary for binary sensitive files(pics, so, etc)
    FileUtils.mkdir_p(File.dirname(options[:path])) if !File.exist?(File.dirname(options[:path]))  
  
    # Resize Main Image
    if options[:resize_image] || options[:effects][:resize_image] == "1" # resize image?
      options[:image].crop_resized!( options[:image_width], options[:image_height] )    
    end
  
    if options[:effects][:monochrome] == "1"
      options[:image] = options[:image].quantize(256, Magick::GRAYColorspace)
    end
  
    if options[:effects][:sepia] == "1"
      options[:image]= options[:image].quantize(256, Magick::GRAYColorspace)
      options[:image] = options[:image].colorize(0.30, 0.30, 0.30, '#cc9933')
    end
  
    if options[:effects][:watermark] == "1" # Watermark 
     watermark_path = Rails.root.to_s + "/public/themes/#{@setting[:theme]}/images/watermark.png"
     if File.exists?(watermark_path) # use existing watermark image
       watermark_image = Magick::Image.from_blob( File.read(watermark_path)).first 
       options[:image].composite!(watermark_image, Magick::CenterGravity, Magick::OverCompositeOp)      
     else # no existing watermark image, generate one from text
       watermark_image = Magick::Image.new(options[:image].columns, options[:image].rows) do # since Image.new returns an actual image, you must initialize image properties(like bg color, etc. in the initialization block of the object) 
         self.background_color = "transparent" # uncomment for Method 2 & 3
       end

       gc = Magick::Draw.new
       gc.gravity = Magick::CenterGravity
       gc.pointsize = 32
       gc.font_family = "Helvetica"
       gc.font_weight = Magick::BoldWeight
       gc.stroke = 'none'
       gc.fill = "black" # uncomment for Method 2 
       gc.annotate(watermark_image, 0, 0, 0, 0, @setting[:title])
  
       # Method 1 - Shade Composite
       #watermark_image = watermark_image.shade(true, 350, 30)  
       #image.composite!(watermark_image, Magick::CenterGravity, Magick::HardLightCompositeOp)
       
       # Method 2 - Image::watermark function
       #image = image.watermark(watermark_image, 0.05, 0, Magick::CenterGravity)
        
       # Method 3 - Transparency 
       #watermark_image.fuzz = 100 # set transparency tolerance
       #watermark_image = watermark_image.transparent("black", (Magick::TransparentOpacity - Magick::OpaqueOpacity) * 0.25) # set opacity     
       options[:image].composite!(watermark_image, Magick::CenterGravity, Magick::OverCompositeOp)  # Other Gravities: SouthEastGravity, NorthGravity(centered), etc. see: http://studio.imagemagick.org/RMagick/doc/constants.html#GravityType for more     
     end
    end

    if options[:effects][:stamp] == "1" # Stamp 
     stamp_path = Rails.root.to_s + "/public/themes/#{@setting[:theme]}/images/stamp.png"
     if File.exists?(stamp_path) # use existing stamp image
       stamp_image = Magick::Image.from_blob( File.read(stamp_path)).first 
       options[:image].composite!(stamp_image, Magick::SouthEastGravity, Magick::OverCompositeOp)  # Other Gravities: SouthEastGravity, NorthGravity(centered), etc.    
     else # no existing stamp image, generate one from text
       logger.info("No Stamp Found: #{stamp_path}")
     end
    end
   
    options[:image] = options[:image].rotate!(90) if options[:effects][:rotate_90_cw] == "1"      
    options[:image] = options[:image].rotate!(-90) if options[:effects][:rotate_90_ccw] == "1"     
    options[:image] = options[:image].rotate!(180) if options[:effects][:rotate_180] == "1"
    #options[:image].resize!(75) if options[:effects][:reduce_25] == "1"    
    #options[:image].resize!(50) if options[:effects][:reduce_50] == "1"      
    #options[:image].resize!(25) if options[:effects][:reduce_75] == "1"          
    options[:image] = options[:image].gaussian_blur(0.0, 3.0) if options[:effects][:gaussian_blur] == "1"     
    options[:image] = options[:image].negate if options[:effects][:negate] == "1"

    if options[:effects][:polaroid] == "1"
      options[:image].border!(10, 10, "#f0f0ff")    
      # Bend the image
      options[:image].background_color = "none"    
      amplitude = options[:image].columns * 0.01        # vary according to taste
      wavelength = options[:image].rows  * 2    
      options[:image].rotate!(90)
      options[:image] = options[:image].wave(amplitude, wavelength)
      options[:image].rotate!(-90)    
      # Make the shadow
      shadow = options[:image].flop
      shadow = shadow.colorize(1, 1, 1, "gray75")     # shadow color can vary to taste
      shadow.background_color = "white"       # was "none"
      shadow.border!(10, 10, "white")
      shadow = shadow.blur_image(0, 3)        # shadow blurriness can vary according to taste      
      # Composite image over shadow. The y-axis adjustment can vary according to taste.
      options[:image] = shadow.composite(options[:image], -amplitude/2, 5, Magick::OverCompositeOp)      
      options[:image].rotate!(-5)                       # vary according to taste
      #image.trim!
    end
    
    
    options[:image].write(options[:path]) # save the normal image
  
    # Create Thumbnail 
    if options[:generate_thumbnail]
      options[:thumbnail_image] = options[:image] # duplicate image for thumbnail
      FileUtils.mkdir_p(File.dirname(options[:thumbnail_path])) if !File.exist?(File.dirname(options[:thumbnail_path])) && options[:thumbnail_path] 
      #file.rewind # rewind the read pointer since create_image was called first
      #image = Magick::Image.from_blob(file.read).first    # read in image binary
      options[:thumbnail_image].crop_resized!(options[:thumbnail_width], options[:thumbnail_height])
      options[:thumbnail_image].write(options[:thumbnail_path])  #save the image     
    end  
 
    return options[:image]
  end  
end
