# MethodFound

[![Gem Version](https://badge.fury.io/rb/method_found.svg)][gem]
[![Build Status](https://travis-ci.org/shioyama/method_found.svg?branch=master)][travis]

[gem]: https://rubygems.org/gems/method_found
[travis]: https://travis-ci.org/shioyama/method_found

Intercept `method_missing` and do something useful with it.

## Installation

Add to your Gemfile:

```ruby
gem 'method_found', '~> 0.1.2'
```

And bundle it.

## Usage

Include an instance of `MethodFound` with a regex to match and block which
takes the method name, regex matches, and arguments and does something with it:

```ruby
class Foo
  include(MethodFound.new(/\Asay_([a-z]+)\Z/) do |method_name, matches, *arguments|
    "#{matches[1]}!"
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

