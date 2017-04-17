require 'spec_helper'

describe MethodFound::Interceptor do
  describe "#inspect" do
    before do
      stub_const 'MyClass', Class.new
      MyClass.include(described_class.new(/foo/) do |*arguments|
        arguments.join
      end)
    end
    let(:instance) { MyClass.new }

    it "prints name and regex" do
      expect(instance.inspect).to match('#<MyClass: /foo/>')
    end
  end
end
