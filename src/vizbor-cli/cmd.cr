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
    puts "1.Add a Mongo driver options file -> config/mongo/options.yml"
      .colorize.fore(:yellow).mode(:bold)
    VizborCLI::Mongo.add_mongo_options
    # Add app settings file.
    puts "2.Add a settings file for your application -> " \
         "src/#{YAML.parse(File.read("shard.yml"))["name"].as_s}/settings.cr"
      .colorize.fore(:yellow).mode(:bold)
    VizborCLI::AppState.add_settings
    # Successful completion.
    puts "Done".colorize.fore(:green).mode(:bold)
    exit 0
  end
end
