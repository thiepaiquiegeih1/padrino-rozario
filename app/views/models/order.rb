# encoding: utf-8
class Order < ActiveRecord::Base
	belongs_to :useraccount, class_name: 'UserAccount'
	belongs_to :status, class_name: 'Status'
	has_many :order_products
end