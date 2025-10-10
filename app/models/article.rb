# encoding: utf-8
class Article < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :seo, dependent: :destroy
  accepts_nested_attributes_for :seo, allow_destroy: true
  validates_presence_of :title
  validates_uniqueness_of :title, :slug
end
