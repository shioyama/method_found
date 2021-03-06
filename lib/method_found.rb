require "securerandom"

require "method_found/version"
require "method_found/builder"
require "method_found/interceptor"
require "method_found/attribute_methods"

module MethodFound
  def self.new(*args, &block)
    Builder.new(*args, &block)
  end
end
