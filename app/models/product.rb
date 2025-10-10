# encoding: utf-8

class Product < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessor \
    :standart_composition,
    :small_composition,
    :lux_composition,
    :first_category_id,
    :quantity,
    :type,
    :discount_price,
    :clean_price,
    :_tags,
    :_complects,
    :promotions,
    :local_price

  has_and_belongs_to_many :categories

  has_many :flowers # deprecated
  has_many :prices  # deprecated

  has_many :product_complects, dependent: :destroy
  has_many :complects, through: :product_complects

  has_many :tag_complects, dependent: :destroy
  has_many :tags, through: :tag_complects

  after_initialize :after_initialize

  belongs_to :seo, dependent: :destroy
  accepts_nested_attributes_for :seo, allow_destroy: true
  validates_uniqueness_of :slug

  def dump_tags(type)
    begin
      product_complects.map do |x|
        c = Complect.find(x.complect_id).title
        next unless c == type
        [c, tag_complects.where(complect_id: x.complect_id).map { |y|
          next unless y.count > 0
          [Tag.find(y.tag_id).title, y.count].join(':')
        }.compact.join(',')].join(':')
      end.compact.first
    rescue
      '-'
    end
  end

  def self.check2(value)
    if value == 'true'
      $value = 'true'
      return 'true'
    else
      $value = 'false'
      return 'false'
    end
  end

  def self.subd(subd)
    if subd == 'true'
      $subd = 'true'
      return 'true'
    else
      $subd = 'false'
      return 'false'
    end
  end

  def thumb_image(mobile = nil)
    config_name = mobile ? 'thumb_size_mobile' : 'thumb_size'
    default = GeneralConfig.where(name: 'default_thumb').first.try(:value)
    config_name = default if default.present? && GeneralConfig.where(name: default).first.present?
    size = GeneralConfig.where(name: config_name).first.try(:value)
    if size.present? && image.present?
      img = get_trick_image
      image.thumb(size) if img.present?
    else
      get_trick_image
    end
  end

  # backward compatibility methods (deprecated)

  def price
    return 0 unless complects.present?
    # if default_price.nil? || default_price == ''; raise StandardError, "`default_price` variable is empty."; end
    begin
      cid = trick_price ? default_price : complects.find_by_title("standard").id
      product_complects.find_by_complect_id(cid).price
    rescue
      0
    end
  end

  def get_discount
    if discount == nil || discount > 100; return 0
    else;                                 return discount; end
  end

  def base_price
    if default_price.nil? || default_price == ''; raise StandardError, "`default_price` variable is empty."; end
    if default_price && trick_price
      begin
        test_p = product_complects.find_by_complect_id(default_price).price
      rescue NoMethodError
        test_p = product_complects.find_by_complect_id(1).price
      end
    else; test_p = product_complects.find_by_complect_id(1).price; end
    return test_p * ((100.0 - get_discount)/100)
  end

  def false_value(complect_id, d)
    array_1990 = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 38, 39, 40, 42, 43, 44, 45, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 85, 86, 92, 94, 95, 102, 103]
    array_2890 = [18, 41, 63, 84, 87, 88, 89, 91, 93, 98, 99, 100, 101]
    array_3790 = [31, 83, 90, 96, 97]
    one = [1]
    severomorsk = [46]
    a = @subdomain['discount_pool_id'].to_json
    product_complect = product_complects.find_by_complect_id(complect_id)
    if    a == '1290'; ord_price = product_complect.price
    elsif a == '1990'; ord_price = product_complect.price_1990
    elsif a == '2890'; ord_price = product_complect.price_2890
    else;              ord_price = product_complect.price_3790; end
    return ord_price
  end

  def special_price_for_other_products(complect_id)
    special_products(complect_id) * ((100.0 - get_discount)/100)
  end

  def price_for_special_rose(complect_id)
    special_price(complect_id) * ((100.0 - get_discount)/100)
  end

  def get_local_complect_clean_price(cart_item, subdomain, subdomain_pool, category)
    complect_id = Complect.find_by_title(cart_item['type']).id
    discount_obj = get_local_discount(subdomain, subdomain_pool, category)
    return complect_clean_price(complect_id) * ((100.0 - discount_obj.discount_in_percents) / 100) + discount_obj.discount_in_rubles
  end

  def special_products(complect_id)
    # puts "<///////////////THIS IS SPECIAL PRODUCTS////////////////////>"
    f = @subdomain_pool.to_json
    d = f.scan(/"id"[+\W+]([\d]+)[,]/).join.to_i
    sbd_tax = Subdomain.where(id: @subdomain)[0]['ordprod'].to_i
    sbd_pl_tax = SubdomainPool.where(id: @subdomain_pool)[0]['ordprod_sp'].to_i
    if $value; ord_price = false_value(complect_id, d)
    else
      product_complect = product_complects.find_by_complect_id(complect_id)
      if    one.include?(d);        ord_price = product_complect.price + (((product_complect.price/100*15).to_f*0.1).round()*10).to_i
      elsif array_1990.include?(d); ord_price = product_complect.over_1990
      elsif array_2890.include?(d); ord_price = product_complect.over_2890
      elsif array_3790.include?(d); ord_price = product_complect.over_3790; end
    end
    return ord_price + sbd_tax + sbd_pl_tax
  end

  def special_price(complect_id)
    # puts "<///////////////THIS IS SPECIAL ROSE////////////////////>"
    f = @subdomain_pool.to_json
    d = f.scan(/"id"[+\W+]([\d]+)[,]/).join.to_i
    sbd_tax = Subdomain.where(id: @subdomain)[0]['101roze'].to_i
    sbd_pl_tax = SubdomainPool.where(id: @subdomain_pool)[0]['101roze_sp'].to_i
    if $value; ord_price = false_value(complect_id, d)
    else
      product_complect = product_complects.find_by_complect_id(complect_id)
      if    one.include?(d);        ord_price = product_complect.price + (((product_complect.price/100*15).to_f*0.1).round()*10).to_i
      elsif array_1990.include?(d); ord_price = product_complect.over_1990
      elsif array_2890.include?(d); ord_price = product_complect.over_2890
      elsif array_3790.include?(d); ord_price = product_complect.over_3790; end
    end
    return ord_price + sbd_tax + sbd_pl_tax
  end

  def complect_clean_price(complect_id)
    # puts "<///////////////THIS IS ORDINARY PRODUCTS////////////////////>"
    f = @subdomain_pool.to_json
    d = f.scan(/"id"[+\W+]([\d]+)[,]/).join.to_i
    sbd_tax = Subdomain.where(id: @subdomain)[0]['overprsubd'].to_i
    sbd_pl_tax = SubdomainPool.where(id: @subdomain_pool)[0]['overprsubd_sp'].to_i
    if $value; ord_price = false_value(complect_id, d)
    else
      product_complect = product_complects.find_by_complect_id(complect_id)
      if one.include?(d);           ord_price = product_complect.price + (((product_complect.price/100*15).to_f*0.1).round()*10).to_i
      elsif array_1990.include?(d); ord_price = product_complect.price_1990 + (((product_complect.price_1990/100*15).to_f*0.1).round()*10).to_i
      elsif array_2890.include?(d); ord_price = product_complect.price_2890 + (((product_complect.price_2890/100*15).to_f*0.1).round()*10).to_i
      elsif array_3790.include?(d); ord_price = product_complect.price_3790 + (((product_complect.price_3790/100*15).to_f*0.1).round()*10).to_i; end
    end
    return ord_price + sbd_tax + sbd_pl_tax
  end

  def complect_price(complect_id)
    complect_clean_price(complect_id) * ((100.0 - get_discount)/100)
  end

  def get_local_discount(subdomain, subdomain_pool, selected_categories)
    product_category = categories.where(id: selected_categories).first
    cat_sub = CategoriesSubdomain.where(subdomain_id: subdomain.id, category_id: selected_categories).first
    cat_subp = CategoriesSubdomainPool.where(subdomain_pool_id: subdomain_pool.id, category_id: selected_categories).first
    if !cat_sub.nil? and cat_sub.discount_status == true and subdomain.enable_categories and cat_sub.discount_period_id !=0
      period = DiscountPeriods.where(id: cat_sub.discount_period_id).first
      if    Date.today >= Date.parse(period.start_date.to_s) and period.end_date.to_s.empty?;                   return cat_sub
      elsif Date.today >= Date.parse(period.start_date.to_s) and Date.today < Date.parse(period.end_date.to_s); return cat_sub
      else;                                                                                                     return product_category; end
    elsif !cat_subp.nil? and cat_subp.discount_status == true and subdomain_pool.enable_categories and cat_subp.discount_period_id !=0
      period = DiscountPeriods.where(id: cat_subp.discount_period_id).first
      if    Date.today >= Date.parse(period.start_date.to_s) and period.end_date.to_s.empty?;                   return cat_subp
      elsif Date.today >= Date.parse(period.start_date.to_s) and Date.today < Date.parse(period.end_date.to_s); return cat_subp
      else;                                                                                                     return product_category; end
    else; return product_category; end
  end

  def get_local_price(subdomain, subdomain_pool, category)
    discount_obj = get_local_discount(subdomain, subdomain_pool, category)
    return base_price * ((100.0 - discount_obj.discount_in_percents) / 100) + discount_obj.discount_in_rubles
  end

  def get_local_complect_price(cart_item, subdomain, subdomain_pool, category, key=0)
    @subdomain = subdomain
    print(@subdomain['id'].to_json, 'SUBDOMAIN')
    @subdomain_pool = subdomain_pool
    cart = cart_item['id'].to_i
    x_101         = [258, 978, 1145, 1183, 1208, 1244, 1255, 1580, 2204, 2230, 2282, 2335, 2367, 2445, 2447, 2499, 2500, 2501, 2553, 2568, 2581, 2585, 2725, 2728, 2746, 2834, 2835]               # deprecated
    special_array = [2853, 2854, 2853, 2853, 2852, 2846, 2988, 2846, 2849, 2855, 2661, 2988, 2662, 2849, 2661, 2849, 2846, 2988, 2661, 2660, 1934, 1934, 1934, 1934, 1937, 1935, 1936, 1845, 2988] # deprecated
    complect_id = Complect.find_by_title(cart_item['type']).id
    discount_obj = get_local_discount(subdomain, subdomain_pool, category)
    deprecated_off = true
    if    x_101.include?(cart)         && !deprecated_off; return price_for_special_rose(complect_id)           * ((100.0 - discount_obj.discount_in_percents) / 100) + discount_obj.discount_in_rubles
    elsif special_array.include?(cart) && !deprecated_off; return special_price_for_other_products(complect_id) * ((100.0 - discount_obj.discount_in_percents) / 100) + discount_obj.discount_in_rubles
    else;                                                  return complect_price(complect_id)                   * ((100.0 - discount_obj.discount_in_percents) / 100) + discount_obj.discount_in_rubles; end
  end

  def self.get_catalog(subdomain, subdomain_pool, categories=nil, tags=nil, min_price=0, max_price=1_000_000, sort_by=nil)
    unless categories # Если список категорий не указан, готовить каталог промоакций...
      product_ids = []; current_time = Time.now
      ProductComplect.where("discounts IS NOT NULL AND discounts != '' AND discounts != '[]' AND discounts != '[]\n' AND discounts != '\n'").each do |product_сomplect|
        begin
          JSON.parse(product_сomplect.discounts).each do |discount|
            percent    = discount["percent"] || 0
            cap        = discount["cap"]     || 0
            shedule    = discount["shedule"] || '* * * * *'
            start_time = convert_to_utc_plus_3(discount["period"]["datetime_start"])
            end_time   = convert_to_utc_plus_3(discount["period"]["datetime_end"])
            if percent > 0 && matches_cron?(shedule) && start_time <= current_time && current_time <= end_time # Проверяем, входит ли текущее время в промежуток
              # result = {
              #   percent: percent,
              #   cap: cap,
              #   shedule: shedule,
              #   period: {
              #     datetime_start: discount["period"]["datetime_start"],
              #     datetime_end: discount["period"]["datetime_end"]
              #   }
              # }
              # product_сomplect.discounts = result.to_json
              unless product_ids.include?(product_сomplect.product_id)
                product_ids.append(product_сomplect.product_id)
              end
            end
          end
        rescue # StandardError => e
          next
        end
      end
    end
    joins = [ # Запрос будет возвращать только те продукты, которые имеют записи в обеих таблицах categories_products и product_complects. Если продукт не присутствует в одной из этих таблиц, он не будет включен в результат.
      'INNER JOIN categories_products ON products.id = categories_products.product_id',
      'INNER JOIN product_complects ON products.id = product_complects.product_id'
    ]
    if categories; products = Product.joins(joins.join(' ')).where('categories_products.category_id' => categories)
    else;          products = Product.where(id: product_ids); end # Каталог промоакций
    unless tags.blank? || tags.empty? # Если неверно, что tags содержит только пробелы или пуст...
      products = products.joins('INNER JOIN products_tags ON products.id = products_tags.product_id').where('products_tags.tag_id' => tags)
    end
    products = products.order(:orderp).uniq
    for product in products
      begin;  product.local_price = product.get_local_price(subdomain, subdomain_pool, categories).ceil
      rescue; product.local_price = product.get_price(subdomain.discount_pool_id); end
    end
    products = products.select{ |p| p.local_price.between?(min_price, max_price) }
    unless sort_by.blank?
      if    sort_by == 'price-desc'; products = products.sort_by(&:local_price).reverse
      elsif sort_by == 'price-asc';  products = products.sort_by(&:local_price)
      else;                          products = products.sort_by(&:header); end
    end
    return products
  end

  def lux_price
    complects.empty? ? 0 : product_complects.find_by_complect_id(complects.find_by_title("lux").id).price
  end

  def small_price
    complects.empty? ? 0 : product_complects.find_by_complect_id(complects.find_by_title("small").id).price
  end

  def image
    begin
      if trick_price; product_complects.find_by_complect_id(default_image).image
      else;           product_complects.find_by_complect_id(complects.find_by_title("standard").id).image; end
    rescue
      ""
    end
  end

  def lux_image
    complects.empty? ? "" : product_complects.find_by_complect_id(complects.find_by_title("lux").id).image
  end

  def small_image
    complects.empty? ? "" : product_complects.find_by_complect_id(complects.find_by_title("small").id).image
  end

  def get_trick_price
    if default_price.nil? || default_price == ''; raise StandardError, "`default_price` variable is empty."; end
    if trick_price && default_price
      product_complects.find_by_complect_id(default_price)&.price || price
    else
      price
    end
  end

  def get_trick_image
    if trick_price
      default_image.nil? ? image : product_complects.find_by_complect_id(default_image).image
    else
      image
    end
  rescue
    ''
  end

  def ordered_prices
    self.prices.order(order: :asc)
  end

  def after_initialize
    #self.title ||=  'Каталог — ' + self.header if self.header.present?
  end

  def get_price(dp_id=1290, round=true)
    if default_price.nil? || default_price == ''; raise StandardError, "`default_price` variable is empty."; end
    if id.nil?;                                   raise StandardError, "`id` variable is empty."; end
    prdct_cmplct_main = ProductComplect.where(product_id: id, complect_id: default_price).first
    if prdct_cmplct_main.nil?;                    raise StandardError, "ProductComplect not found for product_id: #{id} and complect_id: #{default_price}"; end
    return round ? ((prdct_cmplct_main.get_price(dp_id).to_f * 0.1).round * 10).to_i : prdct_cmplct_main.get_price(dp_id)
  end

  def get_cmplct_price(cmplct_id, dp_id=1290, round=true)
    prdct_cmplct = ProductComplect.find_by_id(cmplct_id)
    price = round ? ((prdct_cmplct.get_price(dp_id).to_f*0.1).round()*10).to_i : prdct_cmplct.get_price(dp_id)
    return price
  end

  def get_cmplct_price_by_title(cmplct_title, dp_id=1290, round=true)
    cmplct_type_id = Complect.find_by_title(cmplct_title).id
    prdct_cmplct = nil
    ProductComplect.where(product_id: id).order(created_at: :desc).each { | cmplct | prdct_cmplct = cmplct.complect_id == cmplct_type_id ? cmplct : prdct_cmplct }
    price = prdct_cmplct.nil? ? nil : prdct_cmplct.get_price(dp_id)
    price = round ? ((price.to_f*0.1).round()*10).to_i : price
    return price
  end

  def check_availability(sd_pool) # check availability of the product in the current city
    sd_cat_ls = []; sd_pool.cat_connections.each_with_index { |x, i| sd_cat_ls[i] = x.category_id }
    self.categories.each_with_index { |x, i|
      if !sd_cat_ls.include?(x.id); return false; end
      if i = sd_cat_ls.size - 1; return true; end
    }
  end
end

class CategoriesProducts < ActiveRecord::Base

end
