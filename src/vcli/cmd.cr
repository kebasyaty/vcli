require "yaml"
require "colorize"
require "option_parser"
require "cryomongo"
require "./mongo_options"
require "./app_state"

module VizborCLI
  extend self

  def run(args = ARGV) : Nil
    parse_args args
  end

  def parse_args(args)
    OptionParser.parse(args) do |parser|
      parser.on("-v", "--version", "Print version") { print_version }
      parser.on("-h", "--help", "Show this help") { print_help(parser) }
      parser.on("-i", "--init", "Initializing project.") { init_project }
      #
      parser.missing_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is missing something.".colorize.fore(:red).mode(:bold)
        STDERR.puts ""
        STDERR.puts parser
        exit 1
      end
      parser.invalid_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is not a valid option.".colorize.fore(:red).mode(:bold)
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

  private def init_project
    # Add an Mongo options file.
    VizborCLI::Mongo.add_mongo_options
    puts "1.Added Mongo driver options file -> config/mongo/options.yml"
      .colorize.fore(:yellow).mode(:bold)
    # Add app settings file.
    app_name = VizborCLI::AppState.add_settings
    puts "2.Added settings file for your application -> " \
         "src/#{app_name}/settings.cr".colorize.fore(:yellow).mode(:bold)
    puts "  If necessary, correct the `app_name` parameter."
      .colorize.fore(:blue).mode(:bold)
    # Successful completion.
    puts "Done".colorize.fore(:green).mode(:bold)
    exit 0
  end
end
