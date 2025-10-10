# encoding: utf-8
class Category < ActiveRecord::Base
	include ActiveModel::Validations
	belongs_to :parent, class_name: 'Category'
	has_many :categories, foreign_key: :parent_id
	belongs_to :categorygroup
	has_and_belongs_to_many :products
	has_and_belongs_to_many :categorygroups
#	has_and_belongs_to_many :subdom_menucat, :class_name => 'Subdomain', :join_table => 'subdomains_menu_categories'
	has_many :subdomains, through: :categories_subdomains
	has_many :categories_subdomains, dependent: :destroy
	has_many :subdomain_pools, through: :categories_subdomain_pools
	has_many :categories_subdomain_pools, dependent: :destroy
	belongs_to :slideshow, :class_name => 'Slideshow'
	belongs_to :seo, dependent: :destroy
  accepts_nested_attributes_for :seo, allow_destroy: true
	accepts_nested_attributes_for :products, :allow_destroy => true
  validates_presence_of :title
  validates_uniqueness_of :title, :slug
	mount_uploader :image, UploaderCategory

  def self.vidy
    [["Свадебный букет", 67], ["Композиции", 66], ["Игрушки из цветов", 84], ["Спец предложение", 118], ["101 роза", 733]]
  end
end

class CategoriesCategorygroup < ActiveRecord::Base
	belongs_to :categorygroup
	belongs_to :category
end

class CategoriesSubdomainPool < ActiveRecord::Base
	belongs_to :subdomain_pool
	belongs_to :category
	has_and_belongs_to_many :discount_periods
end

class CategoriesSubdomain < ActiveRecord::Base
	belongs_to :subdomain
	belongs_to :category
	has_and_belongs_to_many :discount_periods
end
