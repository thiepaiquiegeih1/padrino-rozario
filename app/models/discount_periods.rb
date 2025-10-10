# encoding: utf-8
class DiscountPeriods < ActiveRecord::Base
  has_and_belongs_to_many :categories_subdomains
  has_and_belongs_to_many :categories_subdomain_pools
end
