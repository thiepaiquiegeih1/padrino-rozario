# encoding: utf-8
class Tag < ActiveRecord::Base
  has_many :tag_complects, dependent: :destroy
  has_many :products, through: :tag_complects
end
