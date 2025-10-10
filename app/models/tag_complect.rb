# encoding: utf-8
class TagComplect < ActiveRecord::Base
  belongs_to :product
  belongs_to :tag
  belongs_to :complect
end
