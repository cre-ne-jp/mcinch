# frozen_string_literal: true

require_relative '../../test_helper'

class HelperTest < Test::Unit::TestCase
  test 'Sanitize should remove newlines' do
    assert_equal 'ab', Cinch::Helpers.sanitize("a\r\nb")
  end
end
