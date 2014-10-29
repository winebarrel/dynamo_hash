require 'json'
require 'securerandom'
require 'dynamo_hash'

TEST_TABLE_NAME = 'my_table-' + SecureRandom.uuid

def stop_dynalite
  Process.kill 'KILL', $dynalite_pid
end

def start_dynalite
  $dynalite_pid = spawn('dynalite')
end

def query(sql)
  out = `ddbcli --url localhost:4567 -e "#{sql.gsub(/\n/, ' ')}"`
  raise out unless $?.success?
  return out
end

def truncate_table
  query("DELETE ALL FROM #{TEST_TABLE_NAME}")
end

def create_table
  query("CREATE TABLE #{TEST_TABLE_NAME} (id STRING HASH) READ = 20 WRITE = 20")

  loop do
    tables = JSON.parse(query("SHOW TABLES"))
    break if tables.include?(TEST_TABLE_NAME)
  end
end

def select_all
  JSON.parse(query("SELECT ALL * FROM #{TEST_TABLE_NAME}"))
end

def dynamo_hash
  DynamoHash.new(TEST_TABLE_NAME, endpoint: 'http://localhost:4567')
end

RSpec.configure do |config|
  config.before(:all) do
    start_dynalite
    create_table
  end

  config.before(:each) do
    truncate_table
  end

  config.after(:all) do
    stop_dynalite
  end
end
