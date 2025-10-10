# encoding: utf-8
class UploaderSmile < CarrierWave::Uploader::Base

  include CarrierWave::ImageOptimizer
  include CarrierWave::RMagick

  process optimize: [{quality: 50}]
  storage :file

  def fix_filename
    original_filename.gsub!(/\s+/, '_') if original_filename
  end

  ## Manually set root
  def root; File.join(Padrino.root,"public/"); end

  def store_dir
    'uploads/smiles'
  end

  def cache_dir
    Padrino.root("tmp")
  end

  def default_url
    "/images/" + [version_name, "cap1.png"].compact.join('_')
  end

  version :tn do
    process :resize_to_limit => [256, 256]
    def full_filename(for_file = model.logo.file)
      img       = for_file.split('.')
      extension = img[-1]
      name      = img[0...-1].join('.')
      "#{name}_#{version_name}.#{extension}"
    end
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
