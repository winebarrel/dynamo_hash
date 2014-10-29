require 'aws-sdk-core'
require 'dynamo_hash/version'

class DynamoHash
  def initialize(table_name, options = {})
    @table_name = table_name
    @dynamodb = Aws::DynamoDB::Client.new(options)
    table = @dynamodb.describe_table(table_name: table_name.to_s)
    @hash_key = table.table.key_schema.find {|i| i.key_type == 'HASH' }.attribute_name
  end

  def [](key)
    @dynamodb.get_item(
      table_name: @table_name,
      key: { @hash_key => key }
    ).item
  end

  def []=(key, item)
    @dynamodb.put_item(
      table_name: @table_name,
      item: item.merge(@hash_key => key)
    )
  end

  def delete(key)
    @dynamodb.delete_item(
      table_name: @table_name,
      key: { @hash_key => key }
    )
  end
end
