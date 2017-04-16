# MethodFound

Intercept `method_missing` and do something useful with it.

## Installation

Add to your Gemfile:

```ruby
gem 'method_found', '~> 0.1.0'
```

And bundle it.

## Usage

Include an instance of `MethodFound` with a regex to match and block which
takes the method name, regex matches, and arguments and does something with it:

```ruby
class Foo
  include(MethodFound.new(/\Asay_([a-z]+)/Z/) do |method_name, matches, *arguments|
    "#{matches[0]}!"
  end)
end

foo = Foo.new
foo.say_hello
#=> "hello!"
foo.say_bye
#=> "bye!"
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

