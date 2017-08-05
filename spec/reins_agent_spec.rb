# coding: utf-8

# filename: reins_spec.rb
require "spec_helper"

RSpec.describe ReinsAgent do
  it "定数/変数の設定" do
    expect(ReinsAgent::VERSION).not_to be nil
    expect(ReinsAgent.logger).not_to be nil
    expect(ReinsAgent.port).not_to be nil    
  end
end
