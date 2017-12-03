# coding: utf-8

# filename: reins_agent.rb
require "reins_agent/config"
require "reins_agent/version"

require "ipaddr"
require "socket"

module ReinsAgent
  class << self
    def run_agent(port)
      ReinsAgent.logger.info("Reins Agent #{VERSION} を #{port} で起動します")
      throw unless (@cert_key = ReinsAgent.exec("#{ReinsAgent.client_key} auth").chomp)
      ReinsAgent.logger.debug("認証キー : #{@cert_key}")
      @agent = TCPServer.new(ReinsAgent.client_port)
    rescue => e
      ReinsAgent.logger.fatal("Reins Agent が起動できませんでした: #{e}")
      exit
    end

    def define_value(r)
      @addr = IPAddr.new(r.peeraddr[3]).native.to_s
      @keycode, @command, @options = r.gets.chomp.split
      ReinsAgent.logger.debug("addr = #{@addr}, keycode = #{@keycode}, command = #{@command}, options = #{@options}")
    end

    def exit_agent(agent)
      ReinsAgent.logger.info("Reins Agent #{VERSION} を終了します")
      ReinsAgent.exec("#{@cert_key} delete")
      agent.close
      exit
    end
    # サーバへコマンドを送信し、その返り値を取得する
    # == パラメータ
    # command:: サーバへ送信するコマンド+オプションを指定
    # == 返り値
    # response:: サーバからの返り値(改行付き/複数行)
    def exec(command)
      s = TCPSocket.open(ReinsAgent.server_host, ReinsAgent.server_port)
      s.puts command
      response = s.read
      s.close if s
      response
    end
  end

  def start
    agent = run_agent(ReinsAgent.client_port)

    puts ReinsAgent.exec("#{@cert_key} list")

    loop do
      begin
        Thread.start(agent.accept) do |r|
          define_value(r)
          if @cert_key == @keycode
            r.puts("OK")
          end
          r.close
        end
      rescue Interrupt
        exit_agent(agent)
      end
    end
  end

  module_function :start
end
