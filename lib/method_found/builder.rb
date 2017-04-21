module MethodFound
  class Builder < Module
    def initialize(&block)
      instance_eval &block
    end

    def intercept(*args, &block)
      include Interceptor.new(*args, &block)
    end
  end
end
