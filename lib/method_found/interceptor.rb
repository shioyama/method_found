module MethodFound
  class Interceptor < Module
    attr_reader :matcher

    def initialize(regex = nil, &intercept_block)
      define_method_missing(regex, &intercept_block) unless regex.nil?
    end

    def define_method_missing(matcher, &intercept_block)
      @matcher = matcher
      intercept_method = assign_intercept_method(&intercept_block)
      method_cacher    = method(:cache_method)

      define_method :method_missing do |method_name, *arguments, &method_block|
        if matches = matcher.match(method_name)
          method_cacher.(method_name, matches)
          send(method_name, *arguments, &method_block)
        else
          super(method_name, *arguments, &method_block)
        end
      end

      define_method :respond_to_missing? do |method_name, include_private = false|
        if matches = matcher.match(method_name)
          method_cacher.(method_name, matches)
          true
        else
          super(method_name, include_private)
        end
      end
    end

    def inspect
      klass = self.class
      name  = klass.name || klass.inspect
      "#<#{name}: #{matcher.inspect}>"
    end

    private

    def cache_method(method_name, matches)
      intercept_method = @intercept_method
      define_method method_name do |*arguments, &block|
        send(intercept_method, method_name, matches, *arguments, &block)
      end
    end

    def assign_intercept_method(&intercept_block)
      @intercept_method ||= "__intercept_#{SecureRandom.hex}".freeze.tap do |method_name|
        define_method method_name, &intercept_block
      end
    end
  end
end
