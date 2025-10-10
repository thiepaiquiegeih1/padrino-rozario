# encoding: utf-8
class CreateProductComplectRelations < ActiveRecord::Migration
  def self.up
    (basic,small,lux) = ["Стандартный","Уменьшенный","Люкс"].map{ |name| Complect.find_by_title(name) }
    Product.find_each do |product|
      unless product.small_price.nil?
	ProductComplect.create(
	  product_id: product.id,
	  complect_id: small.id,
	  price: product.small_price,
	  image: product.small_image
	)
      end
      unless product.lux_price.nil?
	ProductComplect.create(
	  product_id: product.id,
	  complect_id: lux.id,
	  price: product.lux_price,
	  image: product.lux_image
	)
      end
      ProductComplect.create(
	product_id: product.id,
	complect_id: basic.id,
	price: product.price,
	image: product.image
      )
    end
  end

  def self.down
    ProductComplect.destroy_all
  end
end
