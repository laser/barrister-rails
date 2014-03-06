# barrister-rails

A wrapper for the Barrister Ruby client, for Rails. Transmutes the hashes
representing custom IDL structs to instances of runtime-generated psuedo-models
that implement the ActiveModel interface - allowing them to be consumed easily
by your Rails views.

## Before Getting Started

First, check out Barrister RPC here: http://barrister.bitmechanic.com

## Installation

Add this line to your application's Gemfile:

    gem 'barrister-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install barrister-rails

## A note on the hash-to-model transmute

By default, the Barrister Rails client transmutes hashes (representing structs
in the IDL) to instances of runtime-defined classes that implement the
ActiveModel interface. This allows data from the server to be consumed easily
by Rails' view helpers. Note that these classes will only be created if a
class of the same name cannot be found. If you want to implement your own class
that the Rails client will instantiate, simply define it in app/models using
the name of the struct from the IDL.

## Usage

### Setup

By default, the barrister-rails client assumes your server is reachable via http:

```ruby

c = Barrister::Rails::Client.new 'http://localhost:3001/api'

```

If an alternative transport is desired, simply instantiate it and pass it to the
client's constructor:

```ruby

redis_transport = Barrister::Transports::Redis.new 'some_channel_name'
c = Barrister::Rails::Client.new redis_transport

```

### Initializing a Client

I recommend initializing a client for each interface that you wish to interact with:

```ruby

# config/initializers/user_service_client.rb

class UserServiceClient

  def self.instance
    @@instance ||= create
    @@instance.UserService
  end
 
  def self.create
    Barrister::Rails::Client.new 'http://localhost:3001/api'
  end
  
end

```

### Usage

Upon instantiation, the Barrister client will attempt to pull down the JSON
representation of the IDL file used by the Barrister server. Assuming an
interface has been defined in the IDL, you can call methods on it like so:

```ruby

c = Barrister::Rails::Client.new 'http://localhost:3001/api'

users = c.UserService.get_all_users

puts users

=> [#<User email: "smasd", full_name: "Joe", id: 9, phone_number: "2069990811">,
 #<User email: "smurf", full_name: "Bob", id: 10, phone_number: "234234234">]

```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/barrister-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
