# encoding: utf-8
class Contact < ActiveRecord::Base
  belongs_to :subdomain
  validates :subdomain_id, uniqueness: true
end
