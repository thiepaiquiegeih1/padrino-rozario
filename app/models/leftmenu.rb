# encoding: utf-8
class Leftmenu < ActiveRecord::Base
  has_many :subdomains, foreign_key: :leftmenu_id
  has_many :subdomain_pools, foreign_key: :leftmenu_id
  has_and_belongs_to_many :category, :class_name => 'Category', :join_table => 'leftmenu_cats'
end

class LeftmenuCats < ActiveRecord::Base
	belongs_to :leftmenu
	belongs_to :category
end
