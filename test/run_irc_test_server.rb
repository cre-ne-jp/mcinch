# frozen_string_literal: true

require_relative 'irc_test_server'

server = IRCTestServer.new

quit_server = lambda do |signal|
  puts("Received signal #{signal}")
  server.stop!
end

%i(SIGINT SIGTERM).each do |signal|
  Signal.trap(signal, &quit_server)
end

server.start!
