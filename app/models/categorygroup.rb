# encoding: utf-8
class Categorygroup < ActiveRecord::Base
    has_and_belongs_to_many :categories
    has_and_belongs_to_many :subdomains
    has_and_belongs_to_many :subdomain_pools
end
