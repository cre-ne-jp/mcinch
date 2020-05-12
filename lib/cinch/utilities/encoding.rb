module Cinch
  module Utilities
    # @since 2.0.0
    # @api private
    module Encoding
      def self.encode_incoming(string, encoding)
        string = string.dup
        if encoding == :irc
          # If incoming text is valid UTF-8, it will be interpreted as
          # such. If it fails validation, a CP1252 -> UTF-8 conversion
          # is performed. This allows you to see non-ASCII from mIRC
          # users (non-UTF-8) and other users sending you UTF-8.
          #
          # (from http://xchat.org/encoding/#hybrid)
          string.force_encoding(::Encoding::UTF_8)
          if !string.valid_encoding?
            string.force_encoding(::Encoding::CP1252).encode!(::Encoding::UTF_8, invalid: :replace, undef: :replace)
          end
        else
          string.force_encoding(encoding).encode!(::Encoding::UTF_8, invalid: :replace, undef: :replace)
          string = string.chars.select(&:valid_encoding?).join
        end

        return string
      end

      def self.encode_outgoing(string, encoding)
        string = string.dup
        if encoding == :irc
          encoding = ::Encoding::UTF_8
        end

        return string.encode!(encoding, invalid: :replace, undef: :replace).force_encoding(::Encoding::ASCII_8BIT)
      end
    end
  end
end
