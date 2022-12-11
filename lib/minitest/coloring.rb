# frozen_string_literal: true

require_relative "coloring/version"
require 'minitest'

class Minitest::ColoringReporter < Minitest::Reporter

  module CODE
    ESC = "\e["
    MAGENTA = "#{ESC}35m"
    YELLOW = "#{ESC}33m"
    GREEN = "#{ESC}32m"
    RED = "#{ESC}31m"
    FINISH = "#{ESC}0m"
  end

  def record(result)
    io.print colorize(result)
    io.print CODE::FINISH
  end

  private def colorize(result)
    color_code = case result.result_code
                   when "."
                     CODE::GREEN
                   when "F"
                     CODE::RED
                 end
    "#{color_code}#{result.result_code}"
  end
end

# Minitest::Coloring.color!

# module Minitest
#   class Coloring
#   end
# end