# encoding: utf-8

# Simple test for comments-orders integration
# Test only the model logic without full application loading

# Load minimal dependencies
require 'active_record'
require 'yaml'

# Load database config
db_config = YAML::load_file("config/database.rb") rescue nil

if db_config.nil?
  # Fallback config
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: '127.0.0.1',
    port: 3306,
    encoding: 'utf8',
    database: 'admin_rozario',
    username: 'admin',
    password: ENV['MYSQL_PASSWORD'].to_s
  )
end

# Define minimal models for testing
class Order < ActiveRecord::Base
  has_many :comments, foreign_key: :order_eight_digit_id, primary_key: :eight_digit_id
end

class Comment < ActiveRecord::Base
  belongs_to :order, foreign_key: :order_eight_digit_id, primary_key: :eight_digit_id, optional: true
  
  validates :order_eight_digit_id, 
    numericality: { only_integer: true, greater_than: 9_999_999, less_than: 100_000_000 },
    allow_blank: true
  
  validate :order_exists_if_provided
  
  private
  
  def order_exists_if_provided
    return if order_eight_digit_id.blank?
    
    unless Order.exists?(eight_digit_id: order_eight_digit_id)
      errors.add(:order_eight_digit_id, "Заказ с номером #{order_eight_digit_id} не найден")
    end
  end
end

puts "\n=== Testing Comment-Order Integration ==="

# Test database connection
begin
  connection_info = ActiveRecord::Base.connection.instance_variable_get(:@config)
  puts "✓ Database connected: #{connection_info[:adapter]} - #{connection_info[:database]}"
rescue => e
  puts "✗ Database connection failed: #{e.message}"
  exit 1
end

# Test 1: Check if column exists
begin
  puts "\n1. Checking database schema:"
  
  if Comment.column_names.include?('order_eight_digit_id')
    puts "✓ order_eight_digit_id column exists in comments table"
    
    column = Comment.columns_hash['order_eight_digit_id']
    puts "  - Type: #{column.type}"
    puts "  - Null allowed: #{column.null}"
  else
    puts "✗ order_eight_digit_id column missing!"
    puts "Available columns: #{Comment.column_names.join(', ')}"
  end
  
rescue => e
  puts "✗ Error checking column: #{e.message}"
end

# Test 2: Check existing data
begin
  puts "\n2. Checking existing data:"
  
  comments_count = Comment.count
  orders_count = Order.count
  
  puts "Comments in database: #{comments_count}"
  puts "Orders in database: #{orders_count}"
  
  if orders_count > 0
    order_with_id = Order.where.not(eight_digit_id: nil).first
    if order_with_id
      puts "✓ Found order with eight_digit_id: #{order_with_id.eight_digit_id}"
    else
      puts "! No orders with eight_digit_id found"
    end
  end
  
rescue => e
  puts "✗ Error checking data: #{e.message}"
end

# Test 3: Model validation
begin
  puts "\n3. Testing model validation:"
  
  # Test comment without order (should be valid)
  comment1 = Comment.new(
    name: "Test User",
    body: "Test comment",
    rating: 5.0
  )
  
  if comment1.valid?
    puts "✓ Comment without order is valid"
  else
    puts "✗ Comment validation failed: #{comment1.errors.full_messages.join(', ')}"
  end
  
  # Test with invalid order number format
  comment2 = Comment.new(
    name: "Test User 2",
    body: "Test comment 2",
    rating: 4.0,
    order_eight_digit_id: 123  # Too short
  )
  
  if !comment2.valid? && comment2.errors[:order_eight_digit_id].present?
    puts "✓ Invalid order format rejected: #{comment2.errors[:order_eight_digit_id].first}"
  else
    puts "✗ Should reject invalid order format"
  end
  
  # Test with non-existent but valid format order
  comment3 = Comment.new(
    name: "Test User 3",
    body: "Test comment 3",
    rating: 3.0,
    order_eight_digit_id: 99999999  # Valid format but doesn't exist
  )
  
  if !comment3.valid? && comment3.errors[:order_eight_digit_id].present?
    puts "✓ Non-existent order rejected: #{comment3.errors[:order_eight_digit_id].first}"
  else
    puts "✗ Should reject non-existent order"
  end
  
rescue => e
  puts "✗ Error in validation test: #{e.message}"
end

# Test 4: Association test (if we have data)
begin
  puts "\n4. Testing associations:"
  
  if Order.count > 0 && Comment.count > 0
    order = Order.where.not(eight_digit_id: nil).first
    if order
      comments = order.comments
      puts "Order #{order.eight_digit_id} has #{comments.count} comments"
      
      if comments.count > 0
        comment = comments.first
        puts "✓ Association working: comment #{comment.id} belongs to order #{order.eight_digit_id}"
      end
    end
  else
    puts "! Skipping association test - insufficient data"
  end
  
rescue => e
  puts "✗ Error in association test: #{e.message}"
end

puts "\n=== Test Complete ==="
puts "\nNext steps:"
puts "1. If column missing, add it to database: ALTER TABLE comments ADD COLUMN order_eight_digit_id int(8);"
puts "2. Test the web interface by visiting /comment or /feedback"
puts "3. Check admin interface at /admin/comments"
