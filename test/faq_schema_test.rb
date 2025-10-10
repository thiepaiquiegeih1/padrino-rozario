require 'minitest/autorun'
require 'json'
require 'ostruct'

# Define CURRENT_DOMAIN constant for tests
CURRENT_DOMAIN = 'rozarioflowers.ru' unless defined?(CURRENT_DOMAIN)

# Mock html_safe method for strings (needed for Padrino)
class String
  def html_safe
    self
  end
end

# Test helper class that will receive helper methods
class FAQTestHelper
  def initialize(subdomain = nil)
    @subdomain = subdomain
  end
  
  # Mock content_tag method
  def content_tag(tag, content, attributes = {})
    attr_string = attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    "<#{tag} #{attr_string}>#{content}</#{tag}>"
  end
  
  # Mock request method
  def request
    OpenStruct.new(ssl?: false)
  end
end

# Mock Rozario::App for testing
module Rozario
  class App
    def self.helpers(&block)
      FAQTestHelper.class_eval(&block) if block_given?
      # Also add to test class for direct access
      FAQSchemaTest.class_eval(&block) if defined?(FAQSchemaTest) && block_given?
    end
  end
end

# Declare the test class first so it can receive the helpers
class FAQSchemaTest < Minitest::Test
  # Define mock request method for test context
  def request
    OpenStruct.new(ssl?: false)
  end
  
  # Define mock content_tag method for test context
  def content_tag(tag, content, attributes = {})
    attr_string = attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    "<#{tag} #{attr_string}>#{content}</#{tag}>"
  end
end

# Load the schema helper after setting up mocks
require_relative '../app/helpers/schema_helper'

# Mock subdomain class
class MockSubdomain
  attr_accessor :city, :morph_datel, :morph_predl, :subdomain
  
  def initialize(city)
    @city = city
    case city
    when "Москва"
      @morph_datel = "Москве"
      @morph_predl = "Москве"
      @subdomain = "moscow"
    when "Санкт-Петербург"
      @morph_datel = "Санкт-Петербургу"
      @morph_predl = "Санкт-Петербурге"
      @subdomain = "spb"
    when "Мурманск"
      @morph_datel = "Мурманску"
      @morph_predl = "Мурманске"
      @subdomain = "murmansk"
    else
      @morph_datel = city + "у"
      @morph_predl = city + "е"
      @subdomain = city.downcase
    end
  end
end

# Now define the test methods
class FAQSchemaTest
  def setup
    @helper = FAQTestHelper.new
    @subdomain_moscow = MockSubdomain.new("Москва")
    @helper_moscow = FAQTestHelper.new(@subdomain_moscow)
    
    @subdomain_spb = MockSubdomain.new("Санкт-Петербург") 
    @helper_spb = FAQTestHelper.new(@subdomain_spb)
    
    @subdomain_murmansk = MockSubdomain.new("Мурманск")
    @helper_murmansk = FAQTestHelper.new(@subdomain_murmansk)
  end

  def test_get_default_faq_data_moscow
    @subdomain = @subdomain_moscow
    
    faq_data = send(:get_default_faq_data)
    
    refute_nil faq_data
    assert_equal "Ответы на часто задаваемые вопросы о доставке цветов в Москве", faq_data[:title]
    assert_includes faq_data[:description], "Москве"
    assert_includes faq_data[:questions].first[:question], "Москве"
    
    guarantee_question = faq_data[:questions].find { |q| q[:question].include?("гарантии") }
    refute_nil guarantee_question
    assert_includes guarantee_question[:question], "Москва"
  end

  def test_get_default_faq_data_spb
    @subdomain = @subdomain_spb
    
    faq_data = send(:get_default_faq_data)
    
    assert_includes faq_data[:title], "Санкт-Петербурге"
    assert_includes faq_data[:questions].first[:question], "Санкт-Петербургу"
    
    anonymous_question = faq_data[:questions].find { |q| q[:question].include?("анонимно") }
    refute_nil anonymous_question
    assert_includes anonymous_question[:question], "Санкт-Петербург"
  end

  def test_generate_faq_schema_structure
    @subdomain = @subdomain_moscow
    
    faq_data = send(:get_default_faq_data)
    schema_html = send(:generate_faq_schema, faq_data)
    
    assert_includes schema_html, '<script type="application/ld+json">'
    assert_includes schema_html, '"@context": "https://schema.org"'
    assert_includes schema_html, '"@type": "FAQPage"'
    assert_includes schema_html, '"mainEntity"'
    assert_includes schema_html, '"@type": "Question"'
    assert_includes schema_html, '"acceptedAnswer"'
    assert_includes schema_html, '"@type": "Answer"'
  end

  def test_generate_faq_schema_json_structure
    @subdomain = @subdomain_moscow
    
    faq_data = send(:get_default_faq_data)
    schema_html = send(:generate_faq_schema, faq_data)
    
    # Extract JSON from script tag
    json_match = schema_html.match(/<script[^>]*>(.+?)<\/script>/m)
    refute_nil json_match, "Should contain script tag with JSON"
    
    schema_json = JSON.parse(json_match[1])
    
    assert_equal "https://schema.org", schema_json["@context"]
    assert_equal "FAQPage", schema_json["@type"]
    assert schema_json["mainEntity"].is_a?(Array)
    assert schema_json["mainEntity"].length > 0
    
    first_question = schema_json["mainEntity"].first
    assert_equal "Question", first_question["@type"]
    assert first_question["name"].is_a?(String)
    assert first_question["acceptedAnswer"].is_a?(Hash)
    assert_equal "Answer", first_question["acceptedAnswer"]["@type"]
    assert first_question["acceptedAnswer"]["text"].is_a?(String)
  end

  def test_get_dynamic_url_normal_subdomain
    @subdomain = @subdomain_moscow
    
    url = send(:get_dynamic_url, "/page/dostavka/")
    assert_includes url, "moscow.rozarioflowers.ru"
    assert_includes url, "/page/dostavka/"
    assert_includes url, "http://"
  end

  def test_get_dynamic_url_murmansk_special_case
    @subdomain = @subdomain_murmansk
    
    url = send(:get_dynamic_url, "/page/dostavka/")
    # Should not include murmansk subdomain, should go to root domain
    assert_includes url, "rozarioflowers.ru/page/dostavka/"
    refute_includes url, "murmansk."
  end

  def test_get_dynamic_url_with_full_url
    @subdomain = @subdomain_moscow
    
    url = send(:get_dynamic_url, "https://example.com/test")
    assert_equal "https://example.com/test", url
  end

  def test_faq_data_completeness
    @subdomain = @subdomain_moscow
    
    faq_data = send(:get_default_faq_data)
    
    # Check that all questions have both question and answer
    faq_data[:questions].each do |q|
      refute_empty q[:question], "Question should not be empty"
      refute_empty q[:answer], "Answer should not be empty"
      assert q[:question].is_a?(String)
      assert q[:answer].is_a?(String)
    end
    
    # Should have reasonable number of questions
    assert_operator faq_data[:questions].length, :>=, 5, "Should have at least 5 FAQ questions"
    assert_operator faq_data[:questions].length, :<=, 15, "Should not have too many FAQ questions"
  end

  def test_generate_faq_schema_with_nil_data
    @subdomain = @subdomain_moscow
    
    # Test with completely invalid data structure
    result = send(:generate_faq_schema, { questions: nil })
    assert_equal "", result
  end

  def test_generate_faq_schema_with_empty_questions
    @subdomain = @subdomain_moscow
    
    empty_faq = { title: "Test", description: "Test", questions: [] }
    result = send(:generate_faq_schema, empty_faq)
    assert_equal "", result
  end

  def test_faq_questions_contain_city_specific_content
    @subdomain = @subdomain_moscow
    faq_data_moscow = send(:get_default_faq_data)
    
    @subdomain = @subdomain_spb
    faq_data_spb = send(:get_default_faq_data)
    
    # Find city-specific questions that should be different
    moscow_guarantee = faq_data_moscow[:questions].find { |q| q[:question].include?("гарантии") }
    spb_guarantee = faq_data_spb[:questions].find { |q| q[:question].include?("гарантии") }
    
    assert_includes moscow_guarantee[:question], "Москва"
    assert_includes spb_guarantee[:question], "Санкт-Петербург"
  end

end