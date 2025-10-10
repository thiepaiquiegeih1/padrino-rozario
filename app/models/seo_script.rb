# encoding: utf-8
class SeoScript < ActiveRecord::Base
  validates :title, presence: true
  validates_uniqueness_of :title
end
