require "spec_helper"
require "method_found/attribute_methods"

describe MethodFound::AttributeMethods do
  class ModelWithoutAttributesMethod
    include MethodFound::AttributeMethods
  end
  let(:model_without_attributes) do
    attribute_methods = described_class
    Class.new do
      include attribute_methods
    end
  end

  let(:model_with_attributes) do
    attribute_methods = described_class
    Class.new do
      def initialize(**attrs)
        @foo = attrs[:foo]
        @bar = attrs[:bar]
      end
      include attribute_methods

      attribute_method_prefix 'clear_'
      attribute_method_suffix '='
      attribute_method_affix prefix: 'reset_', suffix: '_to_default!'

      def attributes
        { "foo" => @foo, "bar" => @bar }
      end

      private

      def attribute(name)
        instance_variable_get(:"@#{name}")
      end

      def clear_attribute(name)
        instance_variable_set(:"@#{name}", nil)
      end

      def attribute=(name, value)
        instance_variable_set(:"@#{name}", value)
      end

      def reset_attribute_to_default!(name)
        instance_variable_set(:"@#{name}", "Default #{name.capitalize}")
      end
    end
  end

  describe "#method_missing" do
    context "without attributes" do
      it "correctly raises NoMethodError" do
        expect { model_without_attributes.new.foo }.to raise_error(NoMethodError)
      end
    end

    context "with attributes and matchers" do
      let(:instance) { model_with_attributes.new(foo: "fooval") }

      it "supports getter by default through method_missing" do
        expect(instance.foo).to eq("fooval")
      end

      it "supports prefix methods" do
        instance.clear_foo
        expect(instance.foo).to eq(nil)
      end

      it "supports setter methods" do
        instance.foo = "bar"
        expect(instance.foo).to eq("bar")
      end

      it "supports affix methods" do
        instance.reset_foo_to_default!
        expect(instance.foo).to eq("Default Foo")
      end
    end
  end

  describe ".define_attribute_methods" do
    it "defines attribute methods on class" do
      model_with_attributes.class_eval do
        define_attribute_methods :bar
      end

      instance = model_with_attributes.new(foo: "fooval", bar: "barval")
      expect(instance.methods).not_to include(:foo)
      expect(instance.methods).to include(:bar)

      expect(instance.foo).to eq("fooval")
      expect(instance.bar).to eq("barval")

      # Now methods have been cached, so should be included in both
      expect(instance.methods).to include(:foo)
      expect(instance.methods).to include(:bar)
    end
  end

  describe "#inspect" do
    it "shows regex matchers for all prefixes, suffixes and affixes" do
      ancestors = model_with_attributes.ancestors
      aggregate_failures do
        expect(ancestors[1].inspect).to match /reset_(.*)_to_default/
        expect(ancestors[2].inspect).to match /(.*)#{"(?:=)"}/
        expect(ancestors[3].inspect).to match /clear_(.*)/
      end
    end
  end

  describe ".alias_attribute" do
    it "aliases attribute to new name" do
      model_with_attributes.class_eval do
        alias_attribute :baz, :foo
      end

      instance = model_with_attributes.new(foo: "fooval")
      expect(instance.foo).to eq("fooval")
      expect(instance.baz).to eq("fooval")

      instance.foo = "newval"
      expect(instance.foo).to eq("newval")
      expect(instance.baz).to eq("newval")

      instance.clear_foo
      expect(instance.foo).to eq(nil)
      expect(instance.baz).to eq(nil)
    end
  end
end
