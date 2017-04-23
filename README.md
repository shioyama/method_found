# MethodFound

[![Gem Version](https://badge.fury.io/rb/method_found.svg)][gem]
[![Build Status](https://travis-ci.org/shioyama/method_found.svg?branch=master)][travis]

[gem]: https://rubygems.org/gems/method_found
[travis]: https://travis-ci.org/shioyama/method_found
[docs]: http://www.rubydoc.info/gems/method_found

Intercept `method_missing` and do something useful with it.

## Installation

Add to your Gemfile:

```ruby
gem 'method_found', '~> 0.1.2'
```

And bundle it.

## Usage

Include an instance of `MethodFound::Builder` with a block defining all
patterns to match. Identify a pattern with the `intercept` method, like this:

```ruby
class Foo
  include MethodFound::Builder.new {
    intercept /\Asay_([a-z]+)\Z/ do |method_name, matches, *arguments|
      "#{matches[1]}!"
    end
  }
end
```

Now you can say things:

```ruby
foo = Foo.new
foo.say_hello
#=> "hello!"
foo.say_bye
#=> "bye!"
```

That's it!

## More Information

- [Github repository](https://www.github.com/shioyama/method_found)
- [API documentation][docs]

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
