require 'minitest'

module Minitest

  class Result
    def to_s # :nodoc:
      return location if passed? and not skipped?

      puts failures[0].method(:result_label).source_location
      failures.map do |failure|
        message = failure.message
        message.gsub!("--- expected", "#{ColoringReporter::CODE::GREEN}--- expected#{ColoringReporter::CODE::FINISH}")
        message.gsub!("+++ actual", "#{ColoringReporter::CODE::RED}+++ actual#{ColoringReporter::CODE::FINISH}")
        message.gsub!("Expected:", "#{ColoringReporter::CODE::GREEN}Expected#{ColoringReporter::CODE::FINISH}")
        message.gsub!("Actual:", "#{ColoringReporter::CODE::RED}Actual#{ColoringReporter::CODE::FINISH}")
        "#{ColoringReporter::CODE::RED}#{failure.result_label}#{ColoringReporter::CODE::FINISH}:\n#{self.location}:\n#{message}\n"
      end.join "\n"
    end
  end

  module Reportable
    def location
      loc = " [#{self.failure.location}]" unless passed? or error?
      "#{self.class_name}##{self.name}#{ColoringReporter::CODE::YELLOW}#{loc}#{ColoringReporter::CODE::FINISH}"
    end
  end

  def self.plugin_coloring_options(opts, options)
  end

  def self.plugin_coloring_init(options)
    io = options.fetch(:io, $stdout)
    self.reporter.reporters.reject! { |o| o.is_a? ProgressReporter }
    # self.reporter.reporters.reject! { |o| o.is_a? StatisticsReporter }
    # self.reporter.reporters.reject! { |o| o.is_a? SummaryReporter }
    self.reporter.reporters << ColoringReporter.new(io, options)

    # MEMO StatisticsReporterが情報を収集し、SummaryReporterが詳細を出しているっぽい
    # SummaryReporterはStatisticsReporterを継承していてた
    # MinitestはRunnableなクラスを一つずつ実行していく
    # 各テストはMinitest::Testを継承しており、これはRunnable
    # test.rbがRunnableを定義している
    #
    # TestとResultがRunnableを継承している
    # Testのインスタンスはrunが呼ばれた最後にResult.from selfを呼び出している
    #
    # ResultはStatisticsReporterのresultsに蓄えられ、SummaryReporterのsummaryで出力される
    # summaryの中でResultのto_sが呼ばれる。エラーの場合は Failures:\n <source_code_location>: \n Expected ~~~が返される
    # Expected: ~~ はAssertionのインスタンスのmessageが呼ばれている
    # どこでAssertionにmessageが定義されているか不明
    # => AssertionはExceptionのサブクラスなのでmessageを最初から持っている
    #
    # Expected: ~~ はAssertionsモジュールのdiffメソッドが作っているっぽい。これはassert_equalとかから呼ばれている
    # Assertionインスタンス作成時(raise時)にdiffメソッドが作ったメッセージが使われている
    # なのでdiffメソッドをいじるしかなさそう
  end

end