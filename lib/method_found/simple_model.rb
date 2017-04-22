require "method_found"

module MethodFound
  class SimpleModel
    attr_reader :attribute_builder

    def initialize(*attribute_names, dirty: true, bang: true)
      @attributes = Hash.new { |h, k| h[k] = [] }

      @attribute_builder = builder = Builder.new do
        def define_missing(attribute_name)
          intercept /\A(#{attribute_name})(=|\?)?\Z/ do |method_name, matches, *arguments|
            name  = matches[1]
            value = @attributes[name].last

            if matches[2] == "=".freeze
              new_value = arguments[0]
              @attributes[name].push(new_value) unless new_value == value
            else
              matches[2] == "?".freeze ? !!value : value
            end
          end

          intercept /\A(reset_(#{attribute_name})|(#{attribute_name})_(changed\?|changes))\Z/ do |method_name, matches|
            if matches[1] == "reset_#{attribute_name}".freeze
              !!@attributes.delete(matches[2])
            else
              changes = @attributes[matches[3]]
              matches[4] == "changes".freeze ? changes.reverse : (changes.size > 1)
            end
          end
        end

        intercept /\A(.+)\!\Z/ do |method_name, matches|
          builder.define_missing matches[1]
          singleton_class.include builder
          @attributes[matches[1]].last
        end
      end
      attribute_names.each { |name| builder.define_missing(name) }

      singleton_class.include builder
    end

    def attributes
      Hash[@attributes.map { |k, v| [k, v.last] }]
    end
  end
end
