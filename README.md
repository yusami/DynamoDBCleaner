# DynamoDBCleaner

## Overview

* Delete data in [AWS DynamoDB](https://aws.amazon.com/jp/dynamodb/)

## Description

1. Delete old data in AWS DynamoDB by specified number.
2. Keep the latest data in a month.

## Requirement

* Ruby 3.1
* [AWS SDK for Ruby](https://aws.amazon.com/jp/sdk-for-ruby/)
* AWS credentials

## Install

- Install the gems.

```
$ bundle config set --local path 'vendor/bundle'
$ bundle install  
```

## Usage

* Set the params of `table name`, `key`, `id`.
* Specify the number to delete.

~~~
bc = BulkCleaner.new("sensor-values", "time_sensor", "id005")
bc.delete_items( 10 )
~~~

## Example

~~~
$ ./bulk_cleaner.rb 
==========================
-round: 1/1
-limit: 2
--------------------------
Query items... (table:sensor-values)
Query succeeded.
#<struct Aws::DynamoDB::Types::QueryOutput
 items=
  [{"time"=>"2018-08-30T20:08:09+09:00",
    "distance"=>0.50351858139038086e2,
    "id"=>"id005",
    "time_sensor"=>"2018-08-30T20:08:08+09:00"},
   {"time"=>"2018-08-30T20:08:10+09:00",
    "distance"=>0.5538582801818848e2,
    "id"=>"id005",
    "time_sensor"=>"2018-08-30T20:08:09+09:00"}],
 count=2,
 scanned_count=2,
 last_evaluated_key=
  {"id"=>"id005", "time_sensor"=>"2018-08-30T20:08:09+09:00"},
 consumed_capacity=nil>
[{:delete_request=>
   {:key=>{:id=>"id005", :time_sensor=>"2018-08-30T20:08:08+09:00"}}},
 {:delete_request=>
   {:key=>{:id=>"id005", :time_sensor=>"2018-08-30T20:08:09+09:00"}}}]
--------------------------
Batch delete items...(count:2)
{:request_items=>
  {"sensor-values"=>
    [{:delete_request=>
       {:key=>{:id=>"id005", :time_sensor=>"2018-08-30T20:08:08+09:00"}}},
     {:delete_request=>
       {:key=>{:id=>"id005", :time_sensor=>"2018-08-30T20:08:09+09:00"}}}]}}
Batch delete succeeded.
#<struct Aws::DynamoDB::Types::BatchWriteItemOutput
 unprocessed_items={},
 item_collection_metrics=nil,
 consumed_capacity=nil>
Requested items are deleted successfully.

Complete! (2021-05-05T11:26:28+09:00)
--------------------------
Table data:
-Name         : 'sensor-values'
-Total items  : 19127
-Created      : 2018-01-07 16:05:20 +0900
-Status       : ACTIVE
Deletion:
-time_now     : 2021-05-05T11:26:27+09:00
-delete_before: 2021-04-05T11:26:27+09:00
-time_key     : 'time_sensor'
-delete_id    : 'id005'
-deleted items: 2
~~~

## Licence

* Copyright &copy; 2021-2023 yusami
* Licensed under [MIT License](https://opensource.org/licenses/mit-license.php)

## Author

* [yusami](https://github.com/yusami)
