# encoding: utf-8
class UploaderProduct < CarrierWave::Uploader::Base

  ##
  # Image manipulator library:
  #
  include CarrierWave::ImageOptimizer
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  ##
  # Storage type
  #
  process optimize: [{quality: 50}]
  storage :file
  # configure do |config|
  #   config.fog_credentials = {
  #     :provider              => 'XXX',
  #     :aws_access_key_id     => 'YOUR_ACCESS_KEY',
  #     :aws_secret_access_key => 'YOUR_SECRET_KEY'
  #   }
  #   config.fog_directory = 'YOUR_BUCKET'
  # end
  # storage :fog

  def thumb(size)
    begun_at = Time.now
    size.gsub!(/#/, '!')
    uploader = Class.new(self.class)
    uploader.versions.clear
    uploader.version_names = [size]
    img = uploader.new(model)
    img.retrieve_from_store! "#{file.filename}"
    cached = File.join(CarrierWave.root, img.url)
    unless File.exist?(cached)
      img.cache!(self)
      size = size.split('x').map(&:to_i)
      resizer = case size
                when /[!#]/ then :resize_to_fit
                # add more like when />/ then ...
                else :resize_to_fill
                end
      img.send(resizer, *size)
      img.store!
      logger.debug 'RESIZE', begun_at, img.store_path
    end
    img
  end

  def fix_filename
    original_filename.gsub!(/\s+/, '_') if original_filename
  end

  ## Manually set root
  def root; File.join(Padrino.root,"public/"); end

  ##
  # Directory where uploaded files will be stored (default is /public/uploads)
  #
  def store_dir
    model_name = model.class.to_s.underscore if model
    id = model.try(:id)

    if model_name && id
      "uploads/#{model_name}/#{id}"
    else
      'uploads'
    end
  end
  #def store_dir
  #  'images/uploads'
  #end

  ##
  # Directory where uploaded temp files will be stored (default is [root]/tmp)
  #
  def cache_dir
    Padrino.root("tmp")
  end

  ##
  # Default URL as a default if there hasn't been a file uploaded
  #
  def default_url
    "/images/" + [version_name, "cap1.png"].compact.join('_')
  end

  ##
  # Process files as they are uploaded.
  #
  #process :resize_to_fit => [100, 200]

  ##
  # Create different versions of your uploaded files
  #
  # version :header do
  #   process :resize_to_fill => [940, 250]
  #   version :thumb do
  #     process :resize_to_fill => [230, 85]
  #   end
  # end

  #process :resize_to_fit => [1000, 9999]

  version :thumb_big do
    process :resize_to_fit => [200, 9999]
  end

  version :thumb_sm do
    process :resize_to_fit => [120, 9999]
  end

  version :tn do
    process :resize_to_limit => [256, nil]
  end

  ##
  # White list of extensions which are allowed to be uploaded:
  #
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  ##
  # Override the filename of the uploaded files
  #
  def filename
    #"#{model.randomstring}.#{model.image.file.extension}"
    if original_filename || (file && file.filename)
      @name ||= file.filename ? file.filename.gsub(/(.*_)/,'') : "#{Digest::MD5.hexdigest(File.dirname(current_path))}.#{file.extension}"
    end
  end

end
