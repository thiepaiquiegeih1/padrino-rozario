# encoding: utf-8
class Pattern < ActiveRecord::Base
  validates :slug, uniqueness: true
end
