# frozen_string_literal: true

require "test_helper"

class Minitest::TestColoring < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minitest::Coloring::VERSION
  end

  def test_it_does_something_useful
    assert false
  end

  def test_it_does_something_useful2
    assert true
  end

  def test_it_does_something_useful3
    assert_equal [1], [2]
  end

  def test_it_does_something_useful4
    assert_equal [{id: 1}], [{id: 2}]
  end

  def test_hgehge
    assert_equal "Expected:", "Actual:"
  end
end
