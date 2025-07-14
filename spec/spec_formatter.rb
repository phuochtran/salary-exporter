require 'rspec/core/formatters/base_text_formatter'

class SpecFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :start, :example_passed, :example_failed, :dump_summary

  def init(output)
    super
    @test_number = 0
  end

  def color(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def start(notification)
    @test_number = 0
    output.puts "Starting test suite ...\n"
  end

  def example_passed(notification)
    @test_number += 1
    output.puts "Test case #{@test_number}: #{color('PASSED', 32)} - #{notification.example.full_description}"
  end

  def example_failed(notification)
    @test_number += 1
    output.puts "Test case #{@test_number}: #{color('FAILED', 31)} - #{notification.example.full_description}"
    output.puts "#{notification.exception.message}"
  end

  def dump_summary(summary)
    output.puts "\nTotal: #{summary.example_count}, Passed: #{color(summary.examples.count { |e| e.execution_result.status == :passed }, 32)}, Failed: #{color(summary.failure_count, 31)}, Time: #{summary.duration.round(2)}s"
  end
end
