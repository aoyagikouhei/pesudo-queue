require 'active_record'
require 'uv_util2/config'
require 'pp'
require 'thread'
require './my_queue'


config = UvUtil2::Config.read(
 "./database.yml", 
 :development
)

ActiveRecord::Base.establish_connection(config)

start = Time.now

threads = []
25.times do |i|
  threads << Thread.new do
    flag = true
    while flag do
      ActiveRecord::Base.connection_pool.with_connection do
        data = MyQueue.data(9999)
        if data.nil?
          flag = false
        else
          data.delete
        end
      end
    end
  end
end

threads.each do |it|
  it.join
end

pp Time.now - start
