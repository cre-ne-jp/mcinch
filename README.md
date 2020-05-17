# mcinch

[![Build Status](https://travis-ci.com/ochaochaocha3/mcinch.svg?branch=master)](https://travis-ci.com/ochaochaocha3/mcinch)

mcinch is a fork of Cinch, the excellent IRC bot building framework written in Ruby by Dominik Honnef et al.
Please see [README\_OLD.md](README_OLD.md) for the summary of Cinch.

The aims of this project are:

* To make Cinch easy to embed it into another application.
* To modernize codes to fit them into newer Ruby (>= 2.5).

## Changes from Cinch

* Cinch::Bot#start returns whether the last connection was successful.
  This is useful for host applications to show messages after connection errors.
    * Returns `true` if the last connection was successful (e.g. after calling Cinch::Bot#quit).
    * Returns `false` after giving up the connection to an IRC server due to errors.
* Cinch::Bot#quit quits the bot more gently using the thread for quitting bot.
  Now you can call Cinch::Bot#quit in signal handlers without a ThreadError.
  This is based on [cinchrb/cinch#195](https://github.com/cinchrb/cinch/pull/195).
* Cinch::Utilities::Encoding.encode_incoming always encodes incoming messages to UTF-8.
  Now Cinch bots can connect to IRC servers that use a non-UTF-8 encoding (e.g. ISO-2022-JP) without encoding-related exceptions.
* Method calls passing a Hash as the last argument are modified to pass keyword arguments to suppress warnings in Ruby 2.7.
    * Cinch::Logger#log (calls String#encode)
    * Cinch::Utilities::Encoding.encode_incoming (calls String#encode!)
    * Cinch::Utilities::Encoding.encode_outgoing (calls String#encode!)
