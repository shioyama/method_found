module MethodFound
  class Interceptor < Module
    attr_reader :matcher

    def initialize(matcher = nil, &intercept_block)
      define_method_missing(matcher, &intercept_block) unless matcher.nil?
    end

    def define_method_missing(matcher_, &intercept_block)
      @matcher = matcher = Matcher.new(matcher_)
      assign_intercept_method(&intercept_block)
      method_cacher = method(:cache_method)

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

    class Matcher < Struct.new(:matcher)
      def match(method_name)
        if matcher.is_a?(Regexp)
          matcher.match(method_name)
        elsif matcher.respond_to?(:call)
          matcher.call(method_name) && [method_name.to_s]
        else
          (matcher.to_sym == method_name) && [method_name.to_s]
        end
      end

      def inspect
        matcher.inspect
      end
    end
  end
end
