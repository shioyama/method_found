module MethodFound
  class Interceptor < Module
    attr_reader :regex

    def initialize(regex = nil, &intercept_block)
      define_method_missing(regex, &intercept_block) unless regex.nil?
      define_inspect
    end

    def define_method_missing(regex, &intercept_block)
      @regex = regex
      define_method :method_missing do |method_name, *arguments, &method_block|
        if matches = regex.match(method_name)
          instance_exec(method_name, matches, *arguments, &intercept_block)
        else
          super(method_name, *arguments, &method_block)
        end
      end

      define_method :respond_to_missing? do |method_name, include_private = false|
        (method_name =~ regex) || super(method_name, include_private)
      end
    end

    def define_inspect
      regex = @regex
      define_method :inspect do
        klass = self.class
        name  = klass.name || klass.inspect
        "#<#{name}: #{regex.inspect}>"
      end
    end
  end
end
