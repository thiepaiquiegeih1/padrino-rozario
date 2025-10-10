require 'minitest/autorun'
require 'json'
require 'ostruct'

# Define CURRENT_DOMAIN constant for tests
CURRENT_DOMAIN = 'rozarioflowers.ru' unless defined?(CURRENT_DOMAIN)

# Test helper class that will receive helper methods
class TestHelper
  def initialize(subdomain = nil)
    @subdomain = subdomain
  end
  
  # Mock content_tag method
  def content_tag(tag, content, attributes = {})
    attr_string = attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    "<#{tag} #{attr_string}>#{content}</#{tag}>"
  end
end

# Mock Rozario::App for testing
module Rozario
  class App
    def self.helpers(&block)
      TestHelper.class_eval(&block) if block_given?
    end
  end
end

require_relative '../app/helpers/schema_helper'

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

# Mock subdomain for testing
class MockSubdomain
  attr_accessor :url
  
  def initialize(url = "test")
    @url = url
  end
end

# Add html_safe method to String for compatibility
class String
  def html_safe
    self
  end
end

class SchemaHelperTest < Minitest::Test
  def setup
    @helper = TestHelper.new
    @subdomain = MockSubdomain.new("testcity")
    @helper_with_subdomain = TestHelper.new(@subdomain)
  end
  
  def test_generate_basic_image_schema
    result = @helper.generate_image_schema("https://example.com/image.jpg")
    assert_includes result, '"@context": "https://schema.org"'
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"contentUrl": "https://example.com/image.jpg"'
    assert_includes result, '"author": "Rozario Flowers"'
  end
  
  def test_generate_image_schema_with_options
    options = {
      name: "Test Image",
      description: "Test Description",
      width: "100",
      height: "200"
    }
    result = @helper.generate_image_schema("https://example.com/image.jpg", options)
    assert_includes result, '"name": "Test Image"'
    assert_includes result, '"description": "Test Description"'
    assert_includes result, '"width": "100"'
    assert_includes result, '"height": "200"'
  end
  
  def test_product_image_schema_mobile
    product = MockProduct.new
    result = @helper_with_subdomain.product_image_schema(product, true)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Product"'
    assert_includes result, '"description": "Test Alt"'
    assert_includes result, '"author": "Rozario Flowers"'
    assert_includes result, '"width": "650"'
    assert_includes result, '"height": "650"'
  end
  
  def test_product_image_schema_desktop
    product = MockProduct.new
    result = @helper_with_subdomain.product_image_schema(product, false)
    assert_includes result, '"width": "1315"'
    assert_includes result, '"height": "650"'
  end
  
  
  def test_slide_image_schema
    slide = MockSlide.new
    result = @helper_with_subdomain.slide_image_schema(slide)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Slide"'
    assert_includes result, '"description": "Test Slide"'
    assert_includes result, '"author": "Rozario Flowers"'
  end
  
  def test_full_image_url_with_subdomain
    result = @helper_with_subdomain.send(:full_image_url, "/images/test.jpg")
    assert_equal "https://testcity.rozarioflowers.ru/images/test.jpg", result
  end
  
  def test_full_image_url_already_full
    result = @helper_with_subdomain.send(:full_image_url, "https://example.com/test.jpg")
    assert_equal "https://example.com/test.jpg", result
  end
  
  def test_generated_json_is_valid
    result = @helper.generate_image_schema("https://example.com/image.jpg")
    # Extract JSON from the script tag
    json_match = result.match(/<script[^>]*>(.+)<\/script>/m)
    refute_nil json_match
    
    json_str = json_match[1]
    parsed = JSON.parse(json_str)
    
    assert_equal "https://schema.org", parsed["@context"]
    assert_equal "ImageObject", parsed["@type"]
    assert_equal "https://example.com/image.jpg", parsed["contentUrl"]
    assert_equal "Rozario Flowers", parsed["author"]
  end
  
  def test_handles_missing_methods_gracefully
    broken_product = Object.new
    result = @helper_with_subdomain.product_image_schema(broken_product, true)
    assert_equal "", result
  end
  
  def test_handles_nil_values_gracefully
    result = @helper_with_subdomain.product_image_schema(nil, true)
    assert_equal "", result
  end
  
  def test_smile_image_schema
    smile = OpenStruct.new(images_identifier: "test.jpg", title: "Test Smile", created_at: Time.now)
    result = @helper_with_subdomain.smile_image_schema(smile, "Test Alt Text")
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Alt Text"'
  end
  
  def test_category_image_schema
    category = OpenStruct.new(image: "/test.jpg", title: "Test Category", created_at: Time.now)
    result = @helper_with_subdomain.category_image_schema(category)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Category"'
  end
  
  def test_product_modal_image_schema
    product = MockProduct.new
    result = @helper_with_subdomain.product_modal_image_schema(product, "image")
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"contentUrl": "{{ image }}"'
  end
  
  def test_json_format_no_html_entities
    result = @helper.generate_image_schema("https://example.com/image.jpg")
    # Should contain proper JSON quotes, not HTML entities
    assert_includes result, '"@context"'
    assert_includes result, '"@type"'
    refute_includes result, '&quot;'
    refute_includes result, '&amp;'
  end
  
  def test_schema_methods_handle_errors_gracefully
    # Test with nil/empty parameters
    assert_equal "", @helper.collection_page_schema(nil)
    assert_equal "", @helper.collection_page_schema({})
    assert_equal "", @helper.webpage_schema(nil)
    assert_equal "", @helper.webpage_schema({})
    assert_equal "", @helper.breadcrumb_schema(nil)
    assert_equal "", @helper.breadcrumb_schema([])
  end
end

  # Tests for new CollectionPage and WebPage methods
  
  def test_collection_page_schema_basic
    options = {
      name: "Test Collection",
      description: "A test collection page",
      url: "https://example.com/collection"
    }
    
    result = @helper.collection_page_schema(options)
    json_match = result.match(/<script type="application\/ld\+json">(.+?)<\/script>/m)
    assert json_match, "Should generate script tag"
    
    schema = JSON.parse(json_match[1])
    assert_equal "https://schema.org", schema["@context"]
    assert_equal "CollectionPage", schema["@type"]
    assert_equal "Test Collection", schema["name"]
    assert_equal "A test collection page", schema["description"]
    assert_equal "https://example.com/collection", schema["url"]
  end
  
  def test_collection_page_schema_with_breadcrumbs
    breadcrumbs = [
      { name: "Home", url: "https://example.com/" },
      { name: "Category", url: "https://example.com/category" }
    ]
    
    options = {
      name: "Test Collection",
      url: "https://example.com/collection",
      breadcrumbs: breadcrumbs
    }
    
    result = @helper.collection_page_schema(options)
    json_match = result.match(/<script type="application\/ld\+json">(.+?)<\/script>/m)
    schema = JSON.parse(json_match[1])
    
    assert schema["breadcrumb"], "Should include breadcrumb"
    assert_equal "BreadcrumbList", schema["breadcrumb"]["@type"]
    assert_equal 2, schema["breadcrumb"]["itemListElement"].length
    assert_equal "Home", schema["breadcrumb"]["itemListElement"][0]["item"]["name"]
  end
  
  def test_webpage_schema_basic
    options = {
      name: "Test Web Page",
      description: "A test web page",
      url: "https://example.com/page"
    }
    
    result = @helper.webpage_schema(options)
    json_match = result.match(/<script type="application\/ld\+json">(.+?)<\/script>/m)
    assert json_match, "Should generate script tag"
    
    schema = JSON.parse(json_match[1])
    assert_equal "https://schema.org", schema["@context"]
    assert_equal "WebPage", schema["@type"]
    assert_equal "Test Web Page", schema["name"]
    assert_equal "A test web page", schema["description"]
    assert_equal "https://example.com/page", schema["url"]
    assert schema["author"], "Should include default author"
    assert_equal "Organization", schema["author"]["@type"]
  end
  
  def test_breadcrumb_schema
    items = [
      { name: "Home", url: "https://example.com/" },
      { name: "Category", url: "https://example.com/category" },
      { name: "Product", url: "https://example.com/product" }
    ]
    
    result = @helper.breadcrumb_schema(items)
    json_match = result.match(/<script type="application\/ld\+json">(.+?)<\/script>/m)
    assert json_match, "Should generate script tag"
    
    schema = JSON.parse(json_match[1])
    assert_equal "https://schema.org", schema["@context"]
    assert_equal "BreadcrumbList", schema["@type"]
    assert_equal 3, schema["itemListElement"].length
    
    # Check first item
    first_item = schema["itemListElement"][0]
    assert_equal "ListItem", first_item["@type"]
    assert_equal 1, first_item["position"]
    assert_equal "Home", first_item["item"]["name"]
    assert_equal "https://example.com/", first_item["item"]["@id"]
  end
  # Test organization/florist schema helpers
  def test_organization_florist_schema_generation
    # Mock subdomain with test data
    subdomain = mock_object(
      :url => 'moscow',
      :city => 'Москва',
      :ya_address => 'ул. Ленина, д. 12',
      :suffix => ', Московская область, Россия',
      :contact => nil
    )
    
    # Set instance variable to simulate controller context
    @subdomain = subdomain
    
    # Test schema generation
    schema_output = organization_florist_schema
    
    # Verify it returns valid JSON-LD script tag
    assert_match /<script[^>]*type=["']application\/ld\+json["'][^>]*>/, schema_output
    assert_match /"@context"\s*:\s*"https:\/\/schema.org"/, schema_output
    assert_match /"@type"\s*:\s*"Florist"/, schema_output
    assert_match /"url"\s*:\s*"https:\/\/moscow.rozarioflowers.ru"/, schema_output
    assert_match /"addressLocality"\s*:\s*"Москва"/, schema_output
    assert_match /"streetAddress"\s*:\s*"ул. Ленина, д. 12"/, schema_output
  end
  
  def test_organization_microdata_attributes
    # Mock subdomain with test data
    subdomain = mock_object(
      :url => 'spb',
      :city => 'Санкт-Петербург', 
      :ya_address => 'Невский проспект, д. 25',
      :suffix => ', Ленинградская область, Россия',
      :contact => nil
    )
    
    # Set instance variable to simulate controller context
    @subdomain = subdomain
    
    # Test microdata attributes generation
    attributes = organization_microdata_attributes
    
    # Verify it returns a hash with required attributes
    assert_equal 'Невский проспект, д. 25', attributes[:address]
    assert_equal '+7 (800) 250-64-70', attributes[:telephone]  # fallback phone
    assert_equal 'Розарио Доставка №1', attributes[:name]
    assert_equal 'Mo-Su', attributes[:opening_hours]
    assert_equal 'credit card', attributes[:payment_accepted]
    assert_equal 'info@rozariofl.ru', attributes[:email]
  end
  
  def test_extract_region_from_suffix
    # Test suffix parsing for Russian cities
    assert_equal 'Московская область', extract_region_from_suffix(', Московская область, Россия')
    assert_equal 'Краснодарский край', extract_region_from_suffix(', Краснодарский край, Россия')
    assert_nil extract_region_from_suffix(', Франция')  # No region for foreign countries
    assert_nil extract_region_from_suffix('')
    assert_nil extract_region_from_suffix(nil)
  end
  
  def test_extract_country_from_suffix
    assert_equal 'РУ', extract_country_from_suffix(', Московская область, Россия')
    assert_equal 'FR', extract_country_from_suffix(', Франция')
    assert_equal 'РУ', extract_country_from_suffix('')  # Default
    assert_equal 'РУ', extract_country_from_suffix(nil)  # Default
  end
  
  def test_organization_schema_handles_murmansk_subdomain
    # Mock murmansk subdomain (should use root domain)
    subdomain = mock_object(
      :url => 'murmansk',
      :city => 'Мурманск',
      :ya_address => 'ул. Ленина, д. 12',
      :suffix => ', Мурманская область, Россия', 
      :contact => nil
    )
    
    @subdomain = subdomain
    
    schema_output = organization_florist_schema
    
    # Should use root domain for murmansk
    assert_match /"url"\s*:\s*"https:\/\/rozarioflowers.ru"/, schema_output
  end

  def test_localbusiness_address_data
    # Mock subdomain with Moscow data
    subdomain = mock_object(
      :url => 'moscow',
      :city => 'Москва',
      :ya_address => 'ул. Ленина, д. 12',
      :suffix => ', Московская область, Россия'
    )
    
    @subdomain = subdomain
    
    address_data = localbusiness_address_data
    
    assert_equal 'ул. Ленина, д. 12', address_data[:street_address]
    assert_equal 'Москва', address_data[:locality]
    assert_equal 'Московская область', address_data[:region]
    assert_equal 'РУ', address_data[:country]
    assert_equal '101000', address_data[:postal_code]
  end
