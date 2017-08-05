# coding: utf-8

# filename: reins_agent.rb
require "reins_agent/config"
require "reins_agent/version"

require "ipaddr"
require "socket"

module ReinsAgent
  def exec(command)
    s = TCPSocket.open(ReinsAgent.server_host, ReinsAgent.server_port)
    s.puts command
    response = s.read
    s.close if s
    response
  end

  def start
    exit unless (cert_key = ReinsAgent.exec("#{ReinsAgent.client_key} auth").chomp)

    agent = TCPServer.new(ReinsAgent.client_port)
    ReinsAgent.logger.info("Reins Agent #{VERSION} を #{ReinsAgent.client_port} で起動します")

    puts ReinsAgent.exec("#{cert_key} list")

    loop do
      begin
        Thread.start(agent.accept) do |r|
          addr = IPAddr.new(r.peeraddr[3]).native.to_s
          keycode, command, options = r.gets.chomp.split
          ReinsAgent.logger.debug("addr = #{addr}, keycode = #{keycode}, command = #{command}, options = #{options}")

          if cert_key == keycode
            s.puts("OK")
          end
        end
      rescue Interrupt => e
        ReinsAgent.logger.info(e.to_s)
        ReinsAgent.exec("#{cert_key} delete")
        agent.close
        exit
      end
    end
  end

  module_function :start, :exec
end
