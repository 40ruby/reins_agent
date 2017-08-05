# coding: utf-8

# filename: reins_agent_spec.rb
require "spec_helper"

RSpec.describe ReinsAgent do
  it "定数/変数の設定" do
    expect(ReinsAgent::VERSION).not_to be nil
    expect(ReinsAgent.logger).not_to be nil
    expect(ReinsAgent.client_key).not_to be nil
    expect(ReinsAgent.client_port).not_to be nil
    expect(ReinsAgent.server_host).not_to be nil
    expect(ReinsAgent.server_port).not_to be nil
  end
end
