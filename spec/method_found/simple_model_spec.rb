require "spec_helper"
require "method_found/simple_model"

describe MethodFound::SimpleModel do
  describe "accessors" do
    it "defines accessors on model instance" do
      instance = described_class.new(:title)

      aggregate_failures do
        expect(instance.title).to eq(nil)
        expect(instance.title?).to eq(false)
        instance.title = "foo"
        expect(instance.title).to eq("foo")
        expect(instance.title?).to eq(true)
        instance.title = "bar"
        expect(instance.title).to eq("bar")
        expect(instance.title?).to eq(true)
        instance.title = nil
        expect(instance.title).to eq(nil)
        expect(instance.title?).to eq(false)
      end
    end

    it "works with multiple instances" do
      instance1 = MethodFound::SimpleModel.new(:title)
      instance2 = MethodFound::SimpleModel.new(:foo)
      instance1.title = "title"
      instance2.foo = "foo"

      aggregate_failures do
        expect(instance1.title).to eq("title")
        expect(instance2.foo).to eq("foo")
      end
    end
  end

  describe "dirty tracking" do
    it "defines dirty methods on model instance" do
      instance = described_class.new(:title)

      aggregate_failures do
        expect(instance.title_changed?).to eq(false)
        expect(instance.title_changes).to eq([])
        expect(instance.title_was).to eq(nil)
        instance.title = "foo"
        expect(instance.title_changed?).to eq(false)
        expect(instance.title_changes).to eq(["foo"])
        expect(instance.title_was).to eq(nil)
        instance.title = "bar"
        expect(instance.title_changed?).to eq(true)
        expect(instance.title_changes).to eq(["bar", "foo"])
        expect(instance.title_was).to eq("foo")
        instance.title = "bar"
        expect(instance.title_changed?).to eq(true)
        expect(instance.title_changes).to eq(["bar", "foo"])
        expect(instance.title_was).to eq("foo")
      end
    end

    it "defines reset method on model instance" do
      instance = described_class.new(:title)

      instance.title = "foo"
      instance.title = "bar"
      instance.title = "baz"

      aggregate_failures do
        expect(instance.title).to eq("baz")
        expect(instance.title_changes).to eq(["baz", "bar", "foo"])

        instance.reset_title

        expect(instance.title).to eq(nil)
        expect(instance.title_changes).to eq([])
      end
    end
  end

  describe "bang method" do
    it "defines new method on instance" do
      instance = described_class.new(:foo, :bar)

      expect { instance.baz }.to raise_error(NoMethodError)

      expect(instance.baz!).to eq(nil)
      instance.baz = "value"

      aggregate_failures do
        expect(instance.baz).to eq("value")
        expect(instance.baz?).to eq(true)
        expect(instance.baz_changed?).to eq(false)
        expect(instance.baz_changes).to eq(["value"])
      end
    end
  end

  describe "#attributes" do
    it "returns hash of attributes and their values" do
      instance = described_class.new(:title, :content)

      instance.title = "foo"
      instance.content = "Once upon a time..."
      instance.title = "Title"

      expect(instance.attributes).to eq("title" => "Title", "content" => "Once upon a time...")
    end
  end
end
