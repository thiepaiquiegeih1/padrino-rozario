# encoding: utf-8
class CreateTagComplectRelations < ActiveRecord::Migration
  def self.up
    
    (basic,small,lux) = ["Стандартный","Уменьшенный","Люкс"].map{ |name| Complect.find_by_title(name) }
    
    Product.find_each do |product|
      
      product.flowers.each do |flower|
	
	unless flower.small_count.nil? or flower.small_count <= 0
	  tag = Tag.find_by_title(flower.title)
	  unless tag.nil?
	    tag_complect = TagComplect.create(
	      product_id: product.id,
	      tag_id: tag.id,
	      complect_id: small.id,
	      count: flower.small_count
	    )
	  end
	end
	
	unless flower.lux_count.nil? or flower.lux_count <= 0
	  tag = Tag.find_by_title(flower.title)
	  unless tag.nil?
	    tag_complect = TagComplect.create(
	      product_id: product.id,
	      tag_id: tag.id,
	      complect_id: lux.id,
	      count: flower.lux_count
	    )
	  end
	end
	
	unless flower.standart_count.nil?
	  tag = Tag.find_by_title(flower.title)
	  unless tag.nil?
	    tag_complect = TagComplect.create(
	      product_id: product.id,
	      tag_id: tag.id,
	      complect_id: basic.id,
	      count: flower.standart_count
	    )
	  end
	end
      end
    end
  end

  def self.down
    TagComplect.destroy_all
  end
end
