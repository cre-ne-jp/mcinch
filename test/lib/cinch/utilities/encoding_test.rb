# frozen_string_literal: true

require_relative '../../../test_helper'

class EncodingTest < Test::Unit::TestCase

  data('UTF-8', 'Halò')
  data('CP1252', 'Halò'.encode('CP1252'))
  test 'encode_incoming should encode the given string to UTF-8 if encoding is :mirc' do
    encoded = Cinch::Utilities::Encoding.encode_incoming(data, :irc)
    assert_equal(Encoding::UTF_8, encoded.encoding)
  end

  data('UTF-8', ['Halò', 'UTF-8'])
  data('Shift_JIS (Japanese)', ['こんにちは', 'Shift_JIS'])
  data('ISO-2022-JP (Japanese, dummy)', ['こんにちは', 'ISO-2022-JP'])
  data('GBK (Simplified Chinese)', ['你好', 'GBK'])
  data('Big5 (Traditional Chinese)', ['你好', 'Big5'])
  data('EUC-KR (Korean)', ['여보세요', 'EUC-KR'])
  test 'encode_incoming should encode the given string to UTF-8 if encoding is specified' do
    input_utf_8, encoding = data
    input = input_utf_8.encode(encoding)
    encoded = Cinch::Utilities::Encoding.encode_incoming(input, encoding)

    assert_equal(Encoding::UTF_8, encoded.encoding)
  end
end
