require 'spec_helper'

describe MethodFound do
  it 'has a version number' do
    expect(MethodFound::VERSION).not_to be nil
  end

  it 'matches regex and calls block' do
    klass = Class.new do
      include(MethodFound.new(/\Asay_([a-z]+)\Z/) do |method_name, matches, *arguments|
        "#{matches[1]}!"
      end)
    end
    expect(klass.new.say_hi).to eq("hi!")
    expect(klass.new.say_bye).to eq("bye!")
  end
end
