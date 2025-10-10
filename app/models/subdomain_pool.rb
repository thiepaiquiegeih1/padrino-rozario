# encoding: utf-8
class SubdomainPool < ActiveRecord::Base
    has_many :subdomains, foreign_key: :subdomain_pool_id, :dependent => :nullify
    has_many :categories_subdomain_pools #, dependent: :destroy
    has_many :categories, through: :categories_subdomain_pools
    has_and_belongs_to_many :sbdmpool_menucat, :class_name => 'Category', :join_table => 'subdomain_pools_menu_categories'
    has_and_belongs_to_many :categorygroups
    has_and_belongs_to_many :sbdmpool_menucatgr, :class_name => 'Categorygroup', :join_table => 'subdomain_pools_menu_categorygroups'
    accepts_nested_attributes_for :categories_subdomain_pools, allow_destroy: true

    def all_categories
      categories_by_cg_ids = CategoriesCategorygroup.where(categorygroup_id: categorygroup_ids).pluck(:category_id)
      cat_ids = categories_by_cg_ids + category_ids
      return Category.where(id: cat_ids.uniq)
    end

    def cat_connections
      [].tap do |o|
        self.all_categories.each do |category|
          if c = self.categories_subdomain_pools.find { |cat| cat.category_id == category.id }
            o << c
          else
            o << CategoriesSubdomainPool.new(category: category, subdomain_pool: self)
          end
        end
      end
    end

end
