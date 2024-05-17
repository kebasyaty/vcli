require "yaml"
require "option_parser"
require "cryomongo"
require "./mongo"
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

  private def init_project
    puts "1.Add a Mongo driver options file -> config/mongo/options.yml"
    VizborCLI::Mongo.add_mongo_options
    puts "2.Add a settings file for your application -> " \
         "src/#{YAML.parse(File.read("shard.yml"))["name"].as_s}/settings.cr"
    VizborCLI::AppState.add_settings
    puts "Done"
    exit 0
  end
end
