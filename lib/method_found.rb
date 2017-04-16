require "method_found/version"
require "method_found/interceptor"

module MethodFound
  def self.new(*args, &block)
    Interceptor.new(*args, &block)
  end
end
