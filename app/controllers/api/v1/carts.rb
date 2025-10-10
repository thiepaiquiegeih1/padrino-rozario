# encoding: utf-8
Rozario::App.controllers :carts, map: 'api/v1/carts' do

  post :current_order do
    content_type :json
    session[:init] = true # p session
    params = JSON.parse(request.body.read) || {}
    city_id = params['city_id']
    if city_id != @subdomain.id
      @subdomain = Subdomain.find(city_id)
      session[:subdomain] = @subdomain.id
      @subdomain_pool = SubdomainPool.find(@subdomain.subdomain_pool_id)
    end

    carts = session[:cart] || []
    products = []
    summ_price = 0
    carts.each do |cart|
      product = Product.find(cart["id"])
      if product
        product.quantity = cart["quantity"]
        product.type = cart["type"]
        def product.type_id
          Complect.find_by_title(self.type).id
        end
        def product.cmplct_id
          ProductComplect.where(product_id: self.id, complect_id: self.type_id).order(created_at: :desc)[0].id
        end
        # type_id = Complect.find_by_title(cart["type"]).id
        # cmplct_id = ProductComplect.where(product_id: cart["id"], complect_id: type_id).order(created_at: :desc)[0].id
        product.discount_price = product.get_local_complect_price(cart, @subdomain, @subdomain_pool, product.categories)
        product.clean_price = product.get_local_complect_price(cart, @subdomain, @subdomain_pool, product.categories)
        product.title = product_item2title(cart)
        summ = product.clean_price.to_i * product.quantity.to_i
        summ_price += summ
        products << product
      end
    end
    # TODO: посчитать стоимость доставки
    delivery_price = Subdomain.find(city_id).price || 0

    summ_price += delivery_price.to_i

    return {
      product: products.to_json(
        :only => [:id, :title],
        :methods => [
          :quantity,
          :type,
          :type_id,
          :cmplct_id,
          :discount_price,
          :clean_price
        ]
      ),
      delivery_price: delivery_price,
      summ_price: summ_price
    }.to_json
  end

  post :del do
    params = JSON.parse(request.body.read) || {}
    type = params["type"].present? ? params["type"] : "standard"
    session[:cart].delete_if { |item|
      item["id"].to_i == params["id"].to_i && (item["type"].blank? || item["type"] == type) }
    return true
  end
end
