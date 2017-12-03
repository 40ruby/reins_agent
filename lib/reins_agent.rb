# coding: utf-8

# filename: reins_agent.rb
require "reins_agent/config"
require "reins_agent/version"

require "json"
require "ipaddr"
require "socket"

module ReinsAgent
  class << self
    # サーバへ接続した後、指定したポート番号でサービスを開放する
    # == パラメータ
    # port:: エージェントが起動するためのポート番号
    # == 返り値
    # agent:: 起動されたサービスのソケット情報(@agent でも参照可)
    def run_agent(port)
      ReinsAgent.logger.info("Reins Agent #{VERSION} を #{port} で起動します")

      auth_command = JSON.generate("command" => "auth", "keycode" => ReinsAgent.client_key.to_s)
      throw unless (status = JSON.parse(ReinsAgent.exec(auth_command)))

      @cert_key = status["result"]
      ReinsAgent.logger.debug("認証キー : #{@cert_key} で認証が完了しました")

      @agent = TCPServer.new(ReinsAgent.client_port)
    rescue => e
      ReinsAgent.logger.fatal("Reins Agent が起動できませんでした: #{e}")
      exit
    end

    # サーバからのデータをパースする
    # == パラメータ
    # r:: リモートサーバのソケット情報
    # == 返り値
    # 特になし、ただし @message 連想配列へ、取得した情報を取得
    def define_value(r)
      @message = JSON.parse(r.gets)
      @message["IP address"] = IPAddr.new(r.peeraddr[3]).native.to_s
      ReinsAgent.logger.debug("addr = #{@message['IP address']}, keycode = #{@message['keycode']}, command = #{@message['command']}, options = #{@message['options']}")
    end

    # エージェントの終了処理
    # == パラメータ
    # 特になし
    # == 返り値
    # 常に終了
    def exit_agent
      ReinsAgent.logger.info("Reins Agent #{VERSION} を終了します")
      delete_command = JSON.generate("command" => "delete", "keycode" => @cert_key.to_s)
      ReinsAgent.exec(delete_command)
      @agent.close
      exit
    end

    # サーバへコマンドを送信し、その返り値を取得する
    # == パラメータ
    # command:: サーバへ送信するコマンド+オプションを指定
    # == 返り値
    # response:: サーバからの返り値(改行付き/複数行)
    def exec(command)
      ReinsAgent.logger.debug("コマンドを実行します : #{command}")
      s = TCPSocket.open(ReinsAgent.server_host, ReinsAgent.server_port)
      s.puts command
      response = s.read
      s.close if s
      response
    end

    # サーバからの接続用常駐エージェントを起動
    # == パラメータ
    # 特になし
    # == 返り値
    # 特になし
    def connect_agent
      Thread.start(@agent.accept) do |r|
        define_value(r)
        r.puts("OK")
        r.close
      end
    rescue Interrupt
      exit_agent
    end
  end

  #
  def start
    run_agent(ReinsAgent.client_port)
    list_command = JSON.generate("command" => "list", "keycode" => @cert_key.to_s)
    puts ReinsAgent.exec(list_command)

    loop do
      connect_agent
    end
  end

  module_function :start
end
