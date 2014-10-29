# DynamoHash

It is a library for using DynamoDB HashTable as Ruby Hash

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynamo_hash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamo_hash

## Usage

```ruby
hash = DynamoHash.new('my_table', region: 'ap-notrheast-1')

hash['myid'] = {
  'str'  => 'foo',
  'num'  => 123,
  'strs' => Set['bar', 'zoo', 'baz'],
  'nums' => Set[4, 5, 6]
}

p hash['myid']
#=> {'id'   => 'myid',
#    'str'  => 'foo',
#    'num'  => 123, # BigDecimal
#    'strs' => Set['bar', 'zoo', 'baz'],
#    'nums' => Set[4, 5, 6]} # BigDecimal Set

hash.delete('myid')
```

## Test

```sh
npm install -g dynalite
bundle install
bundle exec rake
```
