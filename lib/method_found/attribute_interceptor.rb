require "method_found"

module MethodFound
=begin

Class defining prefix, suffix and affix methods to a class for a given
attribute name or set of attribute names.

@example
  class Person < Struct.new(:attributes)
    include MethodFound::AttributeInterceptor.new
    include MethodFound::AttributeInterceptor.new(suffix: '=')
    include MethodFound::AttributeInterceptor.new(suffix: '_contrived?')
    include MethodFound::AttributeInterceptor.new(prefix: 'clear_')
    include MethodFound::AttributeInterceptor.new(prefix: 'reset_', suffix: '_to_default!')

    def initialize(attributes = {})
      super(attributes)
    end

    private

    def attribute_contrived?(attr)
      true
    end

    def clear_attribute(attr)
      send("#{attr}=", nil)
    end

    def reset_attribute_to_default!(attr)
      send("#{attr}=", 'Default Name')
    end

    def attribute(attr)
      attributes[attr]
    end

    def attribute=(attr, value)
      attributes[attr] = value
    end
  end
=end
  class AttributeInterceptor < Interceptor
    def initialize(prefix: '', suffix: '')
      @prefix, @suffix = prefix, suffix
      regex_ = regex
      attribute_matcher = proc do |method_name|
        (matches = regex_.match(method_name)) && attributes.include?(matches[1]) && matches[1]
      end
      attribute_matcher.define_singleton_method :inspect do
        regex_.inspect
      end

      super attribute_matcher do |_, attr_name, *arguments, &block|
        send("#{prefix}attribute#{suffix}", attr_name, *arguments, &block)
      end
    end

    def regex
      /\A(?:#{Regexp.escape(@prefix)})(.*)(?:#{Regexp.escape(@suffix)})\z/.freeze
    end

    def define_attribute_methods(*attr_names)
      prefix, suffix = @prefix, @suffix
      attr_names.each do |attr_name|
        define_method "#{@prefix}#{attr_name}#{@suffix}".freeze do |*arguments, &block|
          send("#{prefix}attribute#{suffix}".freeze, attr_name, *arguments, &block)
        end
      end
    end
  end
end
