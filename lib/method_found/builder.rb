module MethodFound
  class Builder < Module
    attr_reader :interceptors

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
