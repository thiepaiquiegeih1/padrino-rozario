# encoding: utf-8
class Slide < ActiveRecord::Base
	belongs_to :slideshow
	mount_uploader :image, UploaderSlide
end