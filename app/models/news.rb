# encoding: utf-8
require 'carrierwave/orm/activerecord'

# my class
class News < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :seo, dependent: :destroy
  accepts_nested_attributes_for :seo, allow_destroy: true
  validates_uniqueness_of :slug

  mount_uploader :image, UploaderNews
end
