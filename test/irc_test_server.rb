# frozen_string_literal: true

require_relative 'test_helper'

require 'socket'
require 'time'

class IRCTestServer
  PORT = 16667
  QUIT_SIGNAL = 'q'

  IRCState = Struct.new(:created_at, :nick, :user, :realname) do
    def accepted?
      [nick, user, realname].all?
    end
  end

  def initialize(output = $stdout)
    @output = output

    @thread = nil
    @signal_r = nil
    @signal_w = nil
  end

  def start!
    return false if @thread

    @signal_r, @signal_w = IO.pipe
    @thread = Thread.new do
      server_thread_proc(PORT, @signal_r)
    end

    @thread.join
    @thread = nil

    @signal_r.close
    @signal_r = nil

    @signal_w.close
    @signal_w = nil

    true
  end

  # Quit the server thread.
  def stop!
    return false unless @thread

    @signal_w.print(QUIT_SIGNAL)
    true
  end

  private

  SocketStore = Struct.new(:signal_r, :server, :client) do
    def ios
      [signal_r, server, client].compact
    end
  end

  # The procedure to run in the server thread.
  # @param [Integer] port TCP port.
  # @param [IO] signal_r IO object to read the quit signal.
  # @return [void]
  def server_thread_proc(port, signal_r)
    TCPServer.open(port) do |server|
      irc_state = IRCState.new(Time.now)

      socket_store = SocketStore.new(signal_r, server, nil)

      @output&.puts("Server is running on #{end_point(server)}...")

      loop do
        stop = handle_readable_ios(socket_store, irc_state)
        break if stop
      end

      socket_store&.client&.close
    end
  end

  # @param [SocketStore] socket_store
  # @param [IRCState] irc_state
  # @return [Boolean] Whether to stop server.
  def handle_readable_ios(socket_store, irc_state)
    readable_ios, = IO.select(socket_store.ios)
    readable_ios.each do |io|
      stop = handle_readable_io(io, socket_store, irc_state)
      return true if stop
    end

    false
  end

  # @param [IO] io IO object to read.
  # @param [SocketStore] socket_store
  # @param [IRCState] irc_state
  # @return [Boolean] Whether to stop server.
  def handle_readable_io(io, socket_store, irc_state)
    case io
    when socket_store.signal_r
      c = io.getc
      return c == QUIT_SIGNAL
    when socket_store.server
      socket_store.client = io.accept
      @output&.puts("Accepted #{end_point(socket_store.client)}.")

      return false
    when socket_store.client
      command = io.gets
      unless command
        @output&.puts("Connection to #{end_point(io)} closed.")
        return true
      end

      read_next_message = eval_irc_message(command.chomp, socket_store, irc_state)
      return !read_next_message
    end
  end

  SPACE = ' '
  NOSPCRLFCL_RE = /[^\x00\x0A\x0D :]/
  NOSPCRLF_RE = /[^\x00\x0A\x0D ]/
  MIDDLE_RE = /#{NOSPCRLFCL_RE}#{NOSPCRLF_RE}*/o
  TRAILING_RE = /[^\x00\x0A\x0D]*/o
  MESSAGE_RE = /\A(?<command>[A-Za-z]+)(?<params>(?: #{MIDDLE_RE})+)?(?: :(?<trailing>#{TRAILING_RE}))?/o

  # @param [String] message IRC message.
  # @param [SocketStore] socket_store
  # @param [IRCState] irc_state
  # @return (see #send_response)
  def eval_irc_message(message, socket_store, irc_state)
    stripped_message = message.strip
    @output&.puts(">> #{stripped_message}")

    m = message.match(MESSAGE_RE)
    unless m
      command, = message.split(SPACE, 2)
      return send_response(err_unknowncommand(command), socket_store.client)
    end

    command = m[:command]
    params = (m[:params] || '').split(SPACE)
    trailing = m[:trailing] || ''

    continue = true
    responses =
      case command.upcase
      when 'CAP'
        []
      when 'NICK'
        eval_nick(params[0], irc_state)
      when 'USER'
        eval_user(*params.slice(0, 3), trailing, socket_store, irc_state)
      when 'QUIT'
        continue = false
        eval_quit(trailing, irc_state)
      else
        err_unknowncommand(command)
      end

    responses.each do |response|
      result = send_response(response, socket_store.client)
      return false unless result
    end

    continue
  end

  def eval_nick(nick, irc_state)
    return '431 :No nickname given' unless nick

    irc_state.nick = nick
    []
  end

  def eval_user(user, _mode, _unused, realname, socket_store, irc_state)
    unless [user, realname].all?
      return err_needmoreparams('USER')
    end

    unless irc_state.nick
      return []
    end

    irc_state.user = user
    irc_state.realname = realname

    [
      "001 #{irc_state.nick} :Welcome to the Internet Relay Network " \
      "#{irc_state.nick}!#{irc_state.user}@#{hostname(socket_store.client)}",
      "002 #{irc_state.nick} :Your host is #{end_point(socket_store.server)}, running version 1.0.0",
      "003 #{irc_state.nick} :This server was created #{irc_state.created_at.rfc2822}",
      "004 #{irc_state.nick} :mcinch 1.0.0 a o"
    ]
  end

  def eval_quit(message, irc_state)
    return [] unless irc_state.accepted?

    error = "ERROR #{irc_state.nick}"
    unless message.empty?
      error += " :#{message}"
    end

    [error]
  end

  # @param [String, nil] response
  # @param [Socket] client
  # @return [true] When sended the response successfully.
  # @return [false] When an error occurred while sending the response.
  def send_response(response, client)
    return false if !response || response.empty?

    response_with_header = ":mcinch #{response}"

    begin
      client.print("#{response_with_header}\r\n")
      @output&.puts("<< #{response_with_header}")

      true
    rescue => e
      @output&.puts("Cannot respond to #{end_point(client)}: #{e}")
      false
    end
  end

  # @param [String] command
  # @return [Array<String>]
  def err_unknowncommand(command)
    ["421 #{command} :Unknown command"]
  end

  # @param [String] command
  # @return [Array<String>]
  def err_needmoreparams(command)
    ["461 #{command} :Not enough parameters"]
  end

  def hostname(socket)
    return nil unless socket

    socket.addr[2]
  end

  def port(socket)
    return nil unless socket

    socket.addr[1]
  end

  # Return the end-point of the socket in the form of <tt>"hostname:port"</tt>.
  # @param [Socket] socket
  # @return [String]
  def end_point(socket)
    return nil unless socket

    "#{hostname(socket)}:#{port(socket)}"
  end
end
