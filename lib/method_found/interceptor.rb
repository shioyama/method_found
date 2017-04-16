module MethodFound
  class Interceptor < Module
    def initialize(regex, &intercept_block)
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
  end
end
