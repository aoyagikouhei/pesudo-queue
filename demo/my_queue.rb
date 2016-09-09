class MyQueue < ActiveRecord::Base
  self.table_name = 'queues'

  class << self
    def data(multiple_count=nil)
      sql = <<-SQL
        SELECT
          t1.queue_id AS id
          ,t1.data
         FROM
           uv_get_data_from_queue(
             p_multiple_count := :multiple_count
           ) AS t1
      SQL
      list = find_by_sql([
        sql,
        multiple_count: multiple_count
      ])
      list.empty? ? nil : list[0]
    end
  end
end
