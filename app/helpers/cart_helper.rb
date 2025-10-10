# encoding: utf-8
Rozario::App.helpers do

  def product_id2title(id)
  	product = Product.find_by_id(id.to_i)
  	product.header
  end

  def product_item2title(item)
    
    product = Product.find_by_id(item["id"].to_i)

    f = ['standard','small','lux','7 rozes','21 rozes','11 rozes','15 rozes','25 rozes','51 rozes','101 rozes','9 chrysanthemum','15 chrysanthemum','21 chrysanthemum','5 peonies','7 peonies','11 peonies','15 peonies','11 chrysanthemum','15 chrysanthemum','25 chrysanthemum','51 chrysanthemum','21  rozes','5 lilies','11 lilies','15 lilies','25 lilies','31 lilies','5 packaging (51 pcs.)','4 packaging (41 pcs.)','2 packaging (21 pcs.)','3 packaging (31 pcs.)','1 packaging (11 pcs.)','1 packaging (5 pcs.)','3 packaging (15 pcs.)','5 packaging (25 pcs.)','7 packaging (35 pcs.)','9 packaging (45 pcs.)','25 tulips', '51 tulips', '101 tulips','15 pcs','25 pcs'];
    r = ['стандартный','уменьшенный','люкс','7 роз','21 роза','11 роз','15 роз','25 роз','51 роза','101 роза','9 хризантем','15 хризантем','21 хризантема','5 пионов','7 пионов','11 пионов','15 пионов','11 хризантем','15 хризантем','25 хризантем','51 хризантема','21 роза','5 лилий','11 лилий','15 лилий','25 лилий','31 лилия','5 упаковок','4 упаковки','2 упаковки','3 упаковки','1 упаковка','1 упаковка','3 упаковки','5 упаковок','7 упаковок','9 упаковок','25 тюльпанов','51 тюльпан','101 тюльпан', '15 шт.', '25 шт.'];
    
    $i = 0
    $num = f.length

    type = item['type'];

    while $i < $num  do
      if (f[$i] == item['type'])
        type = r[$i]; break;
      end
      $i +=1
    end

    "#{product.header} (#{type})"
  end

  def product_id2price(id)
  	product = Product.find_by_id(id.to_i)
  	getprice(product)
  end

  def product_item2price(item)
    product = Product.find_by_id(item["id"].to_i)
    product.product_complects.find_by_complect_id(Complect.find_by_id(item['type']).id).price
  end

  def product_discount_price(item)
    product = Product.find_by_id(item["id"].to_i)
    price = product_item2price(item)
    discount = get_discount(product)
    unless discount.blank? || discount == 0
      price = price - (price * discount.to_f / 100)
    end
    price
  end

  def total
    total = 0
    unless session[:cart].nil?
      session[:cart].each do |item|
        product = Product.find_by_id(item["id"])
        total += product.get_local_complect_price(
            item, @subdomain, @subdomain_pool, product.categories.first
        ) * item["quantity"].to_i
      end
    end
    total.round(2)
  end

  def del_item_url(item)
    return "/cart/del/#{item['id']}?type=#{item['type']}".to_s
  end

  def get_prdct_img(prdct_id, cmplct_type)
    # юзалось это апи, пока не выяснилось, что оно не всегда возвращает корректные данные
    # req = Net::HTTP.post_form(URI.parse('/api/product'), { 'id' => prdct_id })
    # res = JSON.parse(req.body)
    # res['_complects'].each {|x|
    #   if (x['title']==cmplct_type)
    #     return x['image']['image']['url']
    #   end
    # }
    cmplct_type_id = Complect.find_by_title(cmplct_type).id
    cmplcts = ProductComplect.where(product_id: prdct_id)
    cmplcts.each { |x|
      if (x.complect_id==cmplct_type_id)
        return x.image.to_s
      end
    }
  end

  def get_prdct_tn_img(prdct_id, cmplct_type)
    f_path = get_prdct_img(prdct_id, cmplct_type)
    d_path = File.dirname(f_path) 
    ext = File.extname(f_path);
    f_name = File.basename(f_path, ext)+ext;
    tn_f_path = File.join(d_path, f_name)
  end

end