require 'spec_helper'
require 'json'

# Mock classes to simulate the application models
class MockProduct
  attr_accessor :header, :alt, :created_at, :id
  
  def initialize(header: "Test Product", alt: "Test Alt", created_at: nil)
    @header = header
    @alt = alt
    @created_at = created_at || Time.now
    @id = 1
  end
  
  def thumb_image(mobile = false)
    "/images/test_product.jpg"
  end
end

class MockPhoto
  attr_accessor :title, :image, :created_at
  
  def initialize(title: "Test Photo", image: "/images/test_photo.jpg")
    @title = title
    @image = image
    @created_at = Time.now
  end
end

class MockSlide
  attr_accessor :text, :image, :created_at
  
  def initialize(text: "Test Slide", image: "/images/test_slide.jpg")
    @text = text
    @image = image
    @created_at = Time.now
  end
end

# Test helper class that includes SchemaHelper
class TestHelper
  include SchemaHelper
  
  def initialize(subdomain = nil)
    @subdomain = subdomain
  end
  
  # Mock content_tag method
  def content_tag(tag, content, attributes = {})
    attr_string = attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    "<#{tag} #{attr_string}>#{content}</#{tag}>"
  end
end

# Mock subdomain for testing
class MockSubdomain
  attr_accessor :url
  
  def initialize(url = "test")
    @url = url
  end
end

RSpec.describe SchemaHelper do
  let(:helper) { TestHelper.new }
  let(:subdomain) { MockSubdomain.new("testcity") }
  let(:helper_with_subdomain) { TestHelper.new(subdomain) }
  
  describe '#generate_image_schema' do
    it 'generates basic ImageObject schema' do
      result = helper.generate_image_schema("https://example.com/image.jpg")
      expect(result).to include('"@context":"http://schema.org"')
      expect(result).to include('"@type":"ImageObject"')
      expect(result).to include('"contentUrl":"https://example.com/image.jpg"')
      expect(result).to include('"author":"Rozario Flowers"')
    end
    
    it 'includes optional parameters when provided' do
      options = {
        name: "Test Image",
        description: "Test Description",
        width: "100",
        height: "200"
      }
      result = helper.generate_image_schema("https://example.com/image.jpg", options)
      expect(result).to include('"name":"Test Image"')
      expect(result).to include('"description":"Test Description"')
      expect(result).to include('"width":"100"')
      expect(result).to include('"height":"200"')
    end
  end
  
  describe '#product_image_schema' do
    let(:product) { MockProduct.new }
    
    it 'generates schema for product images' do
      result = helper_with_subdomain.product_image_schema(product, true)
      expect(result).to include('"@type":"ImageObject"')
      expect(result).to include('"name":"Test Product"')
      expect(result).to include('"description":"Test Alt"')
      expect(result).to include('"author":"Rozario Flowers"')
      expect(result).to include('"width":"650"')
      expect(result).to include('"height":"650"')
    end
    
    it 'uses different dimensions for desktop' do
      result = helper_with_subdomain.product_image_schema(product, false)
      expect(result).to include('"width":"1315"')
      expect(result).to include('"height":"650"')
    end
  end
  
  
  describe '#slide_image_schema' do
    let(:slide) { MockSlide.new }
    
    it 'generates schema for slideshow slides' do
      result = helper_with_subdomain.slide_image_schema(slide)
      expect(result).to include('"@type":"ImageObject"')
      expect(result).to include('"name":"Test Slide"')
      expect(result).to include('"description":"Test Slide"')
      expect(result).to include('"author":"Rozario Flowers"')
    end
  end
end
