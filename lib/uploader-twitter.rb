# encoding: utf-8
class UploaderTwitter < CarrierWave::Uploader::Base

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
    'uploads/twitter'
  end

  def cache_dir
    Padrino.root("tmp")
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    #"#{model.randomstring}.#{model.image.file.extension}"
    if original_filename || (file && file.filename)
      @name ||= file.filename ? file.filename.gsub(/(.*_)/,'') : "#{Digest::MD5.hexdigest(File.dirname(current_path))}.#{file.extension}"
    end
  end

end
