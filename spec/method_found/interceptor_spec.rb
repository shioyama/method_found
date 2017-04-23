require 'spec_helper'

describe MethodFound::Interceptor do
  describe "when included in a class" do
    context "regex matcher" do
      let(:klass) do
        Class.new do
          def foo; "foo"; end

          include(MethodFound::Interceptor.new(/\A(.+)_with_(.+)\Z/) do |_, matches, &block|
            "#{matches[1]}_with_#{matches[2]}"
          end)

          include(MethodFound::Interceptor.new(/\A(.+)_with_foo\Z/) do |_, matches, &block|
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
        expect(instance).to receive(:respond_to_missing?).once.and_call_original
        expect(instance.respond_to?(:something_else)).to eq(false)
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

    context "proc matcher" do
      let(:klass) do
        Class.new do
          def foo; "foo"; end

          include(MethodFound::Interceptor.new(proc { |name| name == :foobar }) do |_, matches, &block|
            "#{matches[0]}_with_#{foo}#{block && block.call("foobar")}"
          end)
        end
      end

      it "calls intercept block within context of instance" do
        expect(klass.new.foobar).to eq("foobar_with_foo")
      end
    end

    context "string matcher" do
      let(:klass) do
        Class.new do
          def foo; "foo"; end

          include(MethodFound::Interceptor.new("foobar") do |_, matches, &block|
            "#{matches[0]}_with_#{foo}#{block && block.call("foobar")}"
          end)
        end
      end

      it "calls intercept block within context of instance" do
        expect(klass.new.foobar).to eq("foobar_with_foo")
      end
    end
  end

  describe "#inspect" do
    context "regex matcher" do
      subject { described_class.new(/foo/) {} }

      it "prints name and regex" do
        expect(subject.inspect).to match("#<#{described_class.name}: /foo/>")
      end
    end

    context "proc matcher" do
      subject { described_class.new(proc { |expr| true }) {} }

      it "prints name and proc" do
        expect(subject.inspect).to match("#<#{described_class.name}: #<Proc")
      end
    end

    context "string matcher" do
      subject { described_class.new("method_name") {} }

      it "prints name and string" do
        expect(subject.inspect).to match("#<#{described_class.name}: \"method_name\"")
      end
    end
  end
end
