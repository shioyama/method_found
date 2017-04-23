module MethodFound
=begin

Creates set of interceptors to include into a class.

@example
  class Post
    builder = MethodFound::Builder.new {
      intercept /\Asay_([a-z]+)\Z/ do |method_name, matches, *arguments|
        "#{matches[1]}!"
      end

      intercept /\Ayell_([a-z]+)\Z/ do |method_name, matches, *arguments|
        "#{matches[1]}!!!"
      end
    }
  end

  foo = Foo.new
  foo.say_hello
  #=> "hello!"
  foo.yell_hello
  #=> "hello!!!"
=end
  class Builder < Module
    attr_reader :interceptors

    # @yield Yields builder as context to block, to allow calling builder
    #   methods to create interceptors in included class.
    def initialize(&block)
      @interceptors = []
      instance_eval &block
    end

    def intercept(*args, &block)
      @interceptors.push(interceptor = Interceptor.new(*args, &block))
      include interceptor
    end
  end
end
