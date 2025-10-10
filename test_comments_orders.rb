# encoding: utf-8

# Test script for comments-orders integration
# Run with: ruby test_comments_orders.rb

require_relative 'config/boot'

puts "Testing Comment-Order integration..."

# Test 1: Comment model validation
begin
  puts "\n1. Testing Comment model validation:"
  
  # Valid comment without order
  comment1 = Comment.new(
    name: "Test User", 
    body: "Great service!",
    rating: 5.0
  )
  
  if comment1.valid?
    puts "✓ Comment without order_eight_digit_id is valid"
  else
    puts "✗ Error: #{comment1.errors.full_messages.join(', ')}"
  end
  
  # Invalid comment with non-existent order
  comment2 = Comment.new(
    name: "Test User 2",
    body: "Test comment", 
    rating: 4.0,
    order_eight_digit_id: 99999999  # Non-existent order
  )
  
  if !comment2.valid?
    puts "✓ Comment with non-existent order is invalid: #{comment2.errors[:order_eight_digit_id].first}"
  else
    puts "✗ Error: Comment with non-existent order should be invalid"
  end
  
rescue => e
  puts "✗ Error in Comment validation test: #{e.message}"
end

# Test 2: Check if we have any orders to test with
begin
  puts "\n2. Checking for existing orders:"
  
  orders_count = Order.count
  puts "Total orders in database: #{orders_count}"
  
  if orders_count > 0
    sample_order = Order.first
    puts "Sample order ID: #{sample_order.id}, eight_digit_id: #{sample_order.eight_digit_id}"
    
    if sample_order.eight_digit_id
      # Test valid comment with existing order
      comment3 = Comment.new(
        name: "Valid Order User",
        body: "Comment for existing order",
        rating: 4.5,
        order_eight_digit_id: sample_order.eight_digit_id
      )
      
      if comment3.valid?
        puts "✓ Comment with existing order #{sample_order.eight_digit_id} is valid"
      else
        puts "✗ Error: #{comment3.errors.full_messages.join(', ')}"
      end
    else
      puts "! Warning: Sample order has no eight_digit_id"
    end
  else
    puts "! Warning: No orders found in database"
  end
  
rescue => e
  puts "✗ Error in orders test: #{e.message}"
end

# Test 3: Check associations
begin
  puts "\n3. Testing associations:"
  
  # Test Comment belongs_to Order
  if Comment.reflect_on_association(:order)
    puts "✓ Comment has belongs_to :order association"
  else
    puts "✗ Comment missing belongs_to :order association"
  end
  
  # Test Order has_many Comments  
  if Order.reflect_on_association(:comments)
    puts "✓ Order has has_many :comments association"
  else
    puts "✗ Order missing has_many :comments association"
  end
  
rescue => e
  puts "✗ Error in associations test: #{e.message}"
end

# Test 4: Check database column exists
begin
  puts "\n4. Checking database column:"
  
  if Comment.column_names.include?('order_eight_digit_id')
    puts "✓ order_eight_digit_id column exists in comments table"
    
    column_info = Comment.columns_hash['order_eight_digit_id']
    puts "  Column type: #{column_info.type}"
    puts "  Null allowed: #{column_info.null}"
  else
    puts "✗ order_eight_digit_id column missing from comments table"
    puts "Available columns: #{Comment.column_names.join(', ')}"
  end
  
rescue => e
  puts "✗ Error checking database column: #{e.message}"
end

puts "\nTest completed!"
puts "\nTo test the web interface:"
puts "1. Start the application"
puts "2. Navigate to /comment (or /feedback)"
puts "3. Fill out the form with an order number"
puts "4. Check if the comment is saved with the order association"
puts "5. Check the admin interface at /admin/comments to see the order numbers"
