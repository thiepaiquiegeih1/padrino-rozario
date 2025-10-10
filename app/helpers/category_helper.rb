# encoding: utf-8

# Helper methods defined here can be accessed in any controller or view in the application

Rozario::App.helpers do

  def ceil_price_10(price)
    (price / 10).ceil * 10.0
  end

  def ceil_price(price)
    price.ceil
  end

  def getprice(product, send_value = :price)
    discount = get_discount(product)
    price = product.get_trick_price
    unless discount.blank? || discount == 0
      price = price - (price * discount.to_f / 100)
    end
    ceil_price(price)
  end

  def product_clean_price(item)
  	product = Product.find_by_id(item["id"].to_i)
    if item["type"] == "lux"
      price = product.lux_price
    elsif item["type"] == "small"
      price = product.small_price
    else
      price = product.price
    end
  end

  def getprice_lux(product)
    getprice(product, :lux_price)
  end

  def getprice_small(product)
    getprice(product, :small_price)
  end

  def has_discount(product)
    unless product.discount.blank?
      if product.discount > 0 and product.discount <= 100
        return true
      end
    end
    unless product.categories.first.discount.blank?
      if product.categories.first.discount > 0 and product.categories.first.discount <= 100
        return true
      end
    end
    return false
  end

  def get_discount(product)
    unless product.discount.blank?
      if product.discount > 0 and product.discount <= 100
        return product.discount
      end
    end
    unless product.categories.first.discount.blank?
      if product.categories.first.discount > 0 and product.categories.first.discount <= 100
        return product.categories.first.discount
      end
    end
    return 0
  end

  def redclass(product)
    price = getprice(product)
    if price < 1000
      return "three"
    elsif price < 10000
      return "four"
    else
      return ""
    end
  end
end
