# encoding: utf-8
class Page < ActiveRecord::Base
	include ActiveModel::Validations

	after_initialize :after_initialize
	belongs_to :seo, dependent: :destroy
	accepts_nested_attributes_for :seo, allow_destroy: true
	validates_presence_of :header
	validates_uniqueness_of :header, :slug

  def after_initialize
    self.title ||= self.header
  end
end
