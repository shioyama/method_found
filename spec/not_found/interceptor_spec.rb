require 'spec_helper'

describe MethodFound::Interceptor do
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
