require 'spec_helper'

describe MethodFound::Interceptor do
  describe "when included in a class" do
    let(:klass) do
      Class.new do
        def foo
          "foo"
        end

        include(MethodFound::Interceptor.new(/\A(.+)_with_(.+)\Z/) do |method_name, matches, *arguments, &block|
          "#{matches[1]}_with_#{matches[2]}"
        end)

        include(MethodFound::Interceptor.new(/\A(.+)_with_foo\Z/) do |method_name, matches, *arguments, &block|
          "#{matches[1]}_with_#{foo}#{block && block.call("foobar")}"
        end)
      end
    end

    it "calls intercept block within context of instance" do
      expect(klass.new.bar_with_foo).to eq("bar_with_foo")
    end

    it "caches method after first call" do
      instance = klass.new
      expect(instance).to receive(:method_missing).once.and_call_original
      2.times { expect(instance.bar_with_foo).to eq("bar_with_foo") }
      expect(instance).to receive(:method_missing).once.and_call_original
      expect(instance.bar_with_foo).to eq("bar_with_foo")
      expect(instance.baz_with_foo).to eq("baz_with_foo")
    end

    it "caches method after call to respond_to?" do
      instance = klass.new
      expect(instance).to receive(:respond_to_missing?).once.and_call_original
      2.times { expect(instance.respond_to?(:bar_with_foo)).to eq(true) }
    end

    it "works with block argument" do
      expect(klass.new.bar_with_foo do |block_arg|
        "_and_baz_and_#{block_arg}"
      end).to eq("bar_with_foo_and_baz_and_foobar")
    end

    it "falls through to other interceptors" do
      expect(klass.new.baz_with_bar).to eq("baz_with_bar")
    end
  end

  describe "#inspect" do
    subject do
      described_class.new(/foo/) do |*arguments|
        arguments.join
      end
    end

    it "prints name and regex" do
      expect(subject.inspect).to match("#<#{described_class.name}: /foo/>")
    end
  end
end
