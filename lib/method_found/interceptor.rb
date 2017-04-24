module MethodFound
=begin

Class for intercepting method calls using method_missing. Initialized by
passing in a matcher object which can be a Regexp, a proc or lambda, or a
string/symbol.

=end
  class Interceptor < Module
    attr_reader :matcher

    # Creates an interceptor module to include into a class.
    # @param (see #define_method_missing)
    def initialize(matcher = nil, &intercept_block)
      define_method_missing(matcher, &intercept_block) unless matcher.nil?
    end

    # Define method_missing and respond_to_missing? on this interceptor. Can be
    # called after interceptor has been created.
    # @param [Regexp,Proc,String,Symbol] matcher Matcher for intercepting
    #   method calls.
    # @yield [method_name, matches, &block] Yiels method_name matched, set of
    #   matches returned from matcher, and block passed to method when called.
    def define_method_missing(matcher, &intercept_block)
      @matcher = matcher_ = Matcher.new(matcher)
      assign_intercept_method(&intercept_block)
      method_cacher = method(:cache_method)

      define_method :method_missing do |method_name, *arguments, &method_block|
        if matches = matcher_.match(method_name, context: self)
          method_cacher.(method_name, matches)
          send(method_name, *arguments, &method_block)
        else
          super(method_name, *arguments, &method_block)
        end
      end

      define_method :respond_to_missing? do |method_name, include_private = false|
        if matches = matcher_.match(method_name, context: self)
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
        arguments = [matches, *arguments] unless method(intercept_method).arity == 1
        send(intercept_method, method_name, *arguments, &block)
      end
    end

    def assign_intercept_method(&intercept_block)
      @intercept_method ||= "__intercept_#{SecureRandom.hex}".freeze.tap do |method_name|
        define_method method_name, &intercept_block
      end
    end

    class Matcher < Struct.new(:matcher)
      def match(method_name, context:)
        if matcher.is_a?(Regexp)
          matcher.match(method_name)
        elsif matcher.respond_to?(:call)
          context.instance_exec(method_name, &matcher)
        else
          (matcher.to_sym == method_name)
        end
      end

      def inspect
        matcher.inspect
      end
    end
  end
end
