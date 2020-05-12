# frozen_string_literal: true

if ENV["SIMPLECOV"]
  begin
    require 'simplecov'
    SimpleCov.start
  rescue LoadError
  end
end

lib_dir = File.expand_path(File.join('..', 'lib'), __dir__)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'test/unit'

require 'cinch'
