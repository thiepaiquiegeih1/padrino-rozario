# encoding: utf-8
class Slideshow < ActiveRecord::Base
  has_many :slides, :class_name => 'Slide'
  has_many :categories, :class_name => 'Category'
end
