#!/usr/bin/env ruby
# coding: utf-8
require 'bundler'
Bundler.require
require 'aws-sdk-dynamodb'
require 'pp'
require 'date'

# To run on Windows:
require 'os'
if OS.windows?
  Aws.use_bundled_cert!
end

Aws.config.update({
  region: "ap-northeast-1",
})

class BulkCleaner
  def initialize(table_name, time_key, delete_id)

    # SSL options
    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html#initialize-instance_method
    cert_store = OpenSSL::X509::Store.new
    cert_store.set_default_paths

    # DynamoDB
    @dynamoDB = Aws::DynamoDB::Resource.new(:ssl_ca_store => cert_store)
    
    # db client
    @client = Aws::DynamoDB::Client.new(:ssl_ca_store => cert_store)

    # Configs
    @table_name = table_name
    @time_key = time_key
    @delete_id = delete_id
    @delete_unit_by_round = 10.freeze
    @total_deleted_items = 0

    # Time configs
    tt = DateTime.now
    @time_now = tt.iso8601
    @delete_before = (tt << 1).iso8601 # 1 month or earlier
  end

  def query_items( limit )
    # Select the keys to delete
    puts "--------------------------"
    puts "Query items... (table:#{@table_name})";
    params = {
      table_name: @table_name,
      key_condition_expression: "id = :id AND #{@time_key} <= :from",
      expression_attribute_values: {
        ":id" => @delete_id,
        ":from" => @delete_before,
      },
      limit: limit
    }

    items = []
    begin
      # Do query
      result = @client.query(params)
      puts "Query succeeded."

      # Show the result
      pp result
      result.items.each{|item|
        s1 = {
            :delete_request => {
              :key => {
                "id": item["id"],
                "#{@time_key}": item["#{@time_key}"]
              }
            }
           }
        items << s1
      }
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to query table:"
      puts "#{error.message}"
    end
    pp items
  end

  def batch_delete( items )
    puts "--------------------------"
    puts "Batch delete items...(count:#{items.count})";
    params = {
      request_items: {
        @table_name => items
      },
    }
    pp params

    begin
      # Do batch delete
      result = @client.batch_write_item(params)
      puts "Batch delete succeeded."

      # Show the result
      pp result
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to batch delete"
      puts "#{error.message}"
      #STDERR.puts error.backtrace.join("\n")
    end
  end

  def delete_items( total )
    round = (total - 1) / @delete_unit_by_round + 1
    limit = total

    round.times do |i|
      limit = @delete_unit_by_round if limit > @delete_unit_by_round
      if limit <= 0 then
        puts "No more data to delete"
        break
      end

      puts "=========================="
      puts "-round: #{i+1}/#{round}"
      puts "-limit: #{limit}"

      # Query the items to delete
      items = query_items( limit )
      if items.length > 0 then
        # Delete the items
        batch_delete( items )
        @total_deleted_items += items.length
        # Done?
        if @total_deleted_items >= total then
          puts "Requested items are deleted successfully."
          break
        end
        # Next limit
        limit = total - @total_deleted_items
      else
        puts "No items are found to delete."
        break
      end
    end
  end

  def show_table_status
    puts ""
    puts "Complete! (#{Time.now.iso8601})"
    puts "--------------------------"
    puts "Table data:";
    tt = @dynamoDB.table( @table_name )
    puts "-Name         : '#{tt.name}'"
    puts "-Total items  : #{tt.item_count}"
    puts "-Created      : #{tt.creation_date_time}"
    puts "-Status       : #{tt.table_status}"
    puts "Result:"
    puts "-time_now     : #{@time_now}"
    puts "-delete_before: #{@delete_before}"
    puts "-time_key     : '#{@time_key}'"
    puts "-delete_id    : '#{@delete_id}'"
    puts "-deleted items: #{@total_deleted_items}"
  end
end # end of class

if __FILE__ == $0
  bc = BulkCleaner.new("sensor-values", "time_sensor", "id005")
  bc.delete_items( 10 )
  bc.show_table_status
end

