# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Metadata in gemspec.

### Changed

* The repository URL and the author information in gemspec.

## [2.4.0] - 2020-05-18

### Added

* Cinch::Bot#last\_conection\_error [StandardError, nil]: the exception that occurred in the last connection.

### Changed

* Cinch::Bot#start returns whether the last connection was successful.
  This is useful for host applications to show messages after connection errors.
    * Returns `true` if the last connection was successful (e.g. after calling Cinch::Bot#quit).
    * Returns `false` after giving up the connection to an IRC server due to errors.
* Cinch::Bot#quit quits the bot more gently using the thread for quitting bot.
  You can now call Cinch::Bot#quit in signal handlers without a ThreadError.
  This is based on [cinchrb/cinch#195](https://github.com/cinchrb/cinch/pull/195).
* Cinch::Utilities::Encoding.encode_incoming always encodes incoming messages to UTF-8.
  Cinch bots can now connect to IRC servers that use a non-UTF-8 encoding (e.g. ISO-2022-JP) without encoding-related exceptions.
* Method calls passing a Hash as the last argument are modified to pass keyword arguments to suppress warnings in Ruby 2.7.
    * Cinch::Logger#log (calls String#encode)
    * Cinch::Utilities::Encoding.encode_incoming (calls String#encode!)
    * Cinch::Utilities::Encoding.encode_outgoing (calls String#encode!)
