# encoding: utf-8
class Subdomain < ActiveRecord::Base
  validates_presence_of :url, :city
  validates_uniqueness_of :url
  has_one :contact
  has_and_belongs_to_many :disabled_dates, class_name: "DisabledDate"
  has_many :categories_subdomains, dependent: :destroy
  has_many :categories, through: :categories_subdomains
  has_and_belongs_to_many :subdom_cat, :class_name => 'Category', :join_table => 'categories_subdomains'
  has_and_belongs_to_many :subdom_menucat, :class_name => 'Category', :join_table => 'subdomains_menu_categories'
  has_and_belongs_to_many :categorygroups
  has_and_belongs_to_many :overtime_deliveries, :join_table => 'subdomains_overtimedeliveries'
  has_and_belongs_to_many :subdom_menucatgr, :class_name => 'Categorygroup', :join_table => 'subdomains_menu_categorygroups'
  accepts_nested_attributes_for :categories_subdomains, allow_destroy: true

  def self.contact_page_params(subdomain)
    contact_first = Contact.first
    contact_obj = subdomain.contact if subdomain
    header = contact_obj && contact_obj.enabled && contact_obj.header.present? ? contact_obj.header : contact_first.header
    body = contact_obj && contact_obj.enabled && contact_obj.body.present? ? contact_obj.body : contact_first.body
    { header: header, body: body }
  end

  def about_us
    self.contact && self.contact.enabled && self.contact.about_us_short.present? ? self.contact.about_us_short : Contact.first.about_us_short
  end

  def categories
    self.enable_categories ? Category.where(id: self.category_ids.to_s.split(',')) : Category.all
  end

  def all_categories
    categories_by_cg_ids = CategoriesCategorygroup.where(categorygroup_id: categorygroup_ids).pluck(:category_id)
    cat_ids = categories_by_cg_ids + category_ids
    return Category.where(id: cat_ids.uniq)
  end

  def cat_connections
    [].tap do |o|
      self.all_categories.each do |category|
        if c = self.categories_subdomains.find { |cat| cat.category_id == category.id }
          o << c
        else
          o << CategoriesSubdomain.new(category: category, subdomain: self)
        end
      end
    end
  end

  def get_morph(gramme)
    res = morph.nil? ? city : JSON.parse(morph)[gramme]
  end

end
