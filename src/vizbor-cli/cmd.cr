require "option_parser"

module VizborCLI
  extend self

  def run(args = ARGV) : Nil
    parse_args args
  end

  def parse_args(args)
    OptionParser.parse(args) do |parser|
      parser.on("-v", "--version", "Print version") { print_version }
      parser.on("-h", "--help", "Show this help") { print_help(parser) }
      #
      parser.missing_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is missing something."
        STDERR.puts ""
        STDERR.puts parser
        exit 1
      end
      parser.invalid_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is not a valid option."
        STDERR.puts parser
        exit 1
      end
    end
  end

  private def print_version
    puts VERSION
    exit 0
  end

  private def print_help(parser)
    puts parser
    exit 0
  end
end
