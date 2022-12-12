# frozen_string_literal: true

require "./test/test_helper"

class Minitest::TestColoring < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minitest::Coloring::VERSION
  end

  def test_faild_test_shows_red
    assert false
  end

  def test_passed_test_shows_green
    assert true
  end

  def test_skipped_test_shows_yellow
    skip "This test should skip."
    assert_equal [1], [2]
  end

  def test_diff_message_is_colored
    assert_equal [{id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, {id: 1}, ], [{id: 2}]
  end
end
