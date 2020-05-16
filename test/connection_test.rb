# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'irc_test_server'

class ConnectionTest < Test::Unit::TestCase
  setup do
    @bot = Cinch::Bot.new
    @bot.config.server = 'localhost'
    @bot.config.port = 16667
    @bot.config.reconnect = false
    @bot.config.password = nil
    @bot.config.encoding = 'UTF-8'
    @bot.config.nick = 'TestBot'
    @bot.config.user = 'TestBot'
    @bot.config.realname = 'TestBot'
    @bot.loggers.level = :info

    @bot.loggers.delete_at(0)

    @server = IRCTestServer.new(nil)
    @server_thread = Thread.new do
      @server.start!
    end
  end

  teardown do
    @bot.quit

    @server.stop!
    @server_thread.join
  end

  test 'Bot#start should return true when successfully connected to server' do
    sleep(0.1)

    @success = false
    @bot_thread = Thread.new(self) do |t|
      @success = @bot.start
    end

    sleep(0.1)
    @bot.quit
    sleep(0.1)

    assert(@success)
  end

  test 'Bot#start should return false when a connection error occurred' do
    sleep(0.1)

    @bot.config.port = 16668
    @success = false
    @bot_thread = Thread.new(self) do |t|
      @success = @bot.start
    end

    sleep(0.1)

    refute(@success)
  end
end
