# encoding: utf-8
class Complect < ActiveRecord::Base
  has_many :product_complects, dependent: :destroy
  has_many :products, through: :product_complects
  has_many :tag_complects, dependent: :destroy
  has_many :tags, through: :tag_complects
end
