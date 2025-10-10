# encoding: utf-8
require 'carrierwave/orm/activerecord'

class SeoGeneral < ActiveRecord::Base
  include ActiveModel::Validations

  validates :name, presence: true
  mount_uploader :og_image, UploaderOg
  mount_uploader :twitter_image, UploaderTwitter

  attr_accessible :name, :title, :description, :keywords, :h1, :h2, :og_type,
                  :og_title, :og_description, :og_image, :og_url,
                  :og_site_name, :twitter_title, :twitter_description,
                  :twitter_site, :twitter_image, :twitter_image_alt, :index
end
