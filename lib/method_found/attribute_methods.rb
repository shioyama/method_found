require "method_found/attribute_interceptor"

module MethodFound
=begin

@example
  class Person < Struct.new(:attributes)
    include MethodFound::AttributeMethods

    attribute_method_suffix ''
    attribute_method_suffix '='
    attribute_method_suffix '_contrived?'
    attribute_method_prefix 'clear_'
    attribute_method_affix  prefix: 'reset_', suffix: '_to_default!'

    define_attribute_methods :name

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
  module AttributeMethods
    def self.included(base)
      base.include(AttributeInterceptor.new)
      base.instance_eval do
        def attribute_method_prefix(*prefixes)
          prefixes.map { |prefix| include(AttributeInterceptor.new(prefix: prefix)) }
        end

        def attribute_method_suffix(*suffixes)
          suffixes.map { |suffix| include(AttributeInterceptor.new(suffix: suffix)) }
        end

        def attribute_method_affix(*affixes)
          affixes.map { |affix| include(AttributeInterceptor.new(prefix: affix[:prefix], suffix: affix[:suffix])) }
        end

        def define_attribute_methods(*attr_names)
          ancestors.each do |ancestor|
            ancestor.define_attribute_methods(*attr_names) if ancestor.is_a?(AttributeInterceptor)
          end
        end

        def alias_attribute(new_name, old_name)
          ancestors.each do |ancestor|
            ancestor.alias_attribute(new_name, old_name) if ancestor.is_a?(AttributeInterceptor)
          end
        end
      end
    end
  end
end
