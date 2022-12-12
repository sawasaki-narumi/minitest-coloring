require 'minitest'
require 'minitest/coloring'

module Minitest

  def self.plugin_coloring_options(opts, options)
    opts.on "--color", "coloring" do
      options[:color] = true
    end
  end

  def self.plugin_coloring_init(options)
    return unless options[:color]
    io = options.fetch(:io, $stdout)
    self.reporter.reporters.reject! { |o| o.is_a? ProgressReporter }
    self.reporter.reporters << ColoringReporter.new(io, options)
    define_colored_methods
  end

  def self.define_colored_methods
    Result.class_eval do
      def to_s # :nodoc:
        return location if passed? and not skipped?

        failures.map do |failure|
          message = failure.message
          "#{COLOR_CODE::RED}#{failure.result_label}#{COLOR_CODE::FINISH}:\n#{self.location}:\n#{message}\n"
        end.join "\n"
      end
    end

    Reportable.module_eval do
      def location
        loc = " [#{self.failure.location}]" unless passed? or error?
        "#{self.class_name}##{self.name}#{COLOR_CODE::MAGENTA}#{loc}#{COLOR_CODE::FINISH}"
      end
    end

    Assertions.module_eval do
      def diff exp, act
        result = nil

        expect, butwas = things_to_diff(exp, act)

        unless expect
          return "#{COLOR_CODE::GREEN}Expected#{COLOR_CODE::FINISH}: #{COLOR_CODE::GREEN}#{mu_pp exp}#{COLOR_CODE::FINISH}\n  #{COLOR_CODE::RED}Actual#{COLOR_CODE::FINISH}: #{COLOR_CODE::RED}#{mu_pp act}#{COLOR_CODE::FINISH}"
        end

        Tempfile.open("expect") do |a|
          a.puts "#{COLOR_CODE::GREEN}#{expect}#{COLOR_CODE::FINISH}"
          a.flush

          Tempfile.open("butwas") do |b|
            b.puts "#{COLOR_CODE::RED}#{butwas}#{COLOR_CODE::FINISH}"
            b.flush

            result = `#{Minitest::Assertions.diff} #{a.path} #{b.path}`
            result.sub!(/^\-\-\- .+/, "#{COLOR_CODE::GREEN}--- expected#{COLOR_CODE::FINISH}")
            result.sub!(/^\+\+\+ .+/, "#{COLOR_CODE::RED}+++ actual#{COLOR_CODE::FINISH}")
            result.sub!(/^\-/, "#{COLOR_CODE::GREEN}-#{COLOR_CODE::FINISH}")
            result.sub!(/^\+/, "#{COLOR_CODE::RED}+#{COLOR_CODE::FINISH}")

            if result.empty? then
              klass = exp.class
              result = [
                "No visible difference in the #{klass}#inspect output.\n",
                "You should look at the implementation of #== on ",
                "#{klass} or its members.\n",
                expect,
              ].join
            end
          end
        end

        result
      end
    end
  end

  class ColoringReporter < Minitest::Reporter

    def record(result)
      io.print colorize(result)
      io.print COLOR_CODE::FINISH
    end

    private def colorize(result)
      color_code = case result.result_code
                     when "."
                       COLOR_CODE::GREEN
                     when "F"
                       COLOR_CODE::RED
                     when "S"
                       COLOR_CODE::YELLOW
                   end
      "#{color_code}#{result.result_code}"
    end
  end

  module COLOR_CODE
    ESC = "\e["
    MAGENTA = "#{ESC}35m"
    YELLOW = "#{ESC}33m"
    GREEN = "#{ESC}32m"
    RED = "#{ESC}31m"
    FINISH = "#{ESC}0m"
  end

end