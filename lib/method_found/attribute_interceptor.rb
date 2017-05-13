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
      @regex = regex = /\A(?:#{Regexp.escape(@prefix)})(.*)(?:#{Regexp.escape(@suffix)})\z/
      @method_missing_target = method_missing_target = "#{prefix}attribute#{suffix}"
      @method_name = "#{prefix}%s#{suffix}"

      attribute_matcher = proc do |method_name|
        (matches = regex.match(method_name)) &&
          methods.include?(:attributes) &&
          attributes.include?(matches[1]) &&
          matches[1]
      end
      attribute_matcher.define_singleton_method :inspect do
        regex.inspect
      end

      super attribute_matcher do |_, attr_name, *args, &block|
        send(method_missing_target, attr_name, *args, &block)
      end
    end

    def define_attribute_methods(*attr_names)
      prefix, suffix, handler = @prefix, @suffix, @method_missing_target
      attr_names.each do |attr_name|
        define_method method_name(attr_name) do |*arguments, &block|
          send(handler, attr_name, *arguments, &block)
        end
      end
    end

    def alias_attribute(new_name, old_name)
      prefix, suffix, handler = @prefix, @suffix, method_name(old_name)
      define_method method_name(new_name) do |*arguments, &block|
        send(handler, *arguments, &block)
      end
    end

    private

    def method_name(attr_name)
      @method_name % attr_name
    end
  end
end
