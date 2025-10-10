# encoding: utf-8
class OvertimeDelivery < ActiveRecord::Base
  has_and_belongs_to_many :subdomains, :join_table => 'subdomains_overtimedeliveries'

  def start_time_short
    start_time.strftime("%H:%M") unless start_time.nil?
  end

  def end_time_short
    end_time.strftime("%H:%M") unless end_time.nil?
  end
end
