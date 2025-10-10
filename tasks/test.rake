namespace :orders do

  desc "orders support tasks"

  task :ch_status => :environment do

    orders = Order.where(status_id: 1)
    orders.each do |order|
      diff = TimeDifference.between(order.created_at, Time.now).in_minutes
      if diff >= 20
        order.status_id = 2
        order.save
      end
    end

    orders = Order.where(status_id: 2)
    orders.each do |order|
      puts order.user_datetime.to_s
      if order.user_datetime <= Time.now
        order.status_id = 3
        order.save
      end
    end

  end

end