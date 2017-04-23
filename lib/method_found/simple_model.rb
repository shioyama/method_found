require "method_found"

module MethodFound
=begin

Example class using MethodFound interceptors to implement attributes and change
tracking. Symbols passed into constructor define patterns in interceptor
modules to catch method calls and define methods on module as needed. New
methods can be dynamically defined by calling any undefined method with a bang (!).

This class is not included by default when requiring MethodFound, so you will need to explicitly require it with:

  require "method_found/simple_model"

@example Setting Attributes
  post = MethodFound::SimpleModel.new(:title, :content)

  post.title = "Method Found"
  post.content = "Once upon a time..."

  post.title
  #=> "Method Found"

  post.content
  #=> "Once upon a time..."

@example Dyanamically defining new attributes
  post = MethodFound::SimpleModel.new

  post.foo
  #=> raises MethodNotFound error

  post.foo!
  #=> nil

  post.foo = "my foo"
  post.foo
  #=> "my foo"

@example Tracking changes
  post = MethodFound::SimpleModel.new(:title)

  post.title = "foo"
  post.title_changed?
  #=> false

  post.title = "bar"
  post.title_changed?
  #=> true
  post.title_was
  #=> "foo"
  post.title_changes
  #=> ["bar", "foo"]

=end
  class SimpleModel
    attr_reader :attribute_builder

    # @param attribute_names [Symbol] One or more attribute names to define
    #   interceptors for on model.
    def initialize(*attribute_names)
      @attributes = Hash.new { |h, k| h[k] = [] }

      @attribute_builder = builder = Builder.new do
        def define_missing(attribute_name)
          intercept /\A(#{attribute_name})(=|\?)?\Z/.freeze do |_, matches, *arguments|
            name  = matches[1]
            value = @attributes[name].last

            if matches[2] == "=".freeze
              new_value = arguments[0]
              @attributes[name].push(new_value) unless new_value == value
            else
              matches[2] == "?".freeze ? !!value : value
            end
          end

          intercept /\A(reset_(#{attribute_name})|(#{attribute_name})_(changed\?|changes|was))\Z/.freeze do |_, matches|
            if matches[1] == "reset_#{attribute_name}".freeze
              !!@attributes.delete(matches[2])
            else
              changes = @attributes[matches[3]]
              if matches[4] == "changes".freeze
                changes.reverse
              elsif matches[4] == "was".freeze
                changes[-2]
              else
                changes.size > 1
              end
            end
          end
        end

        intercept /\A(.+)\!\Z/ do |_, matches|
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
