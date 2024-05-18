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
      parser.on("-i", "--init", "Initialize project") { init_project }
      parser.on("-a NAME", "--add=NAME", "Add a new service") { |name| add_service(name) }
      parser.on("-d NAME", "--delete=NAME", "Delete service") { |name| delete_service(name) }
      parser.on(
        "-r USERNAME",
        "--restore=USERNAME",
        "Restore access to admin panel",
      ) { |username| restore_access(username) }
      #
      parser.missing_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is missing something."
          .colorize.fore(:red).mode(:bold)
        STDERR.puts ""
        STDERR.puts parser
        exit 1
      end
      parser.invalid_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is not a valid option."
          .colorize.fore(:red).mode(:bold)
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
    VizborCLI::MongoOptions.add_mongo_options
    puts "1.Added Mongo driver options file -> config/mongo/options.yml"
      .colorize.fore(:yellow).mode(:bold)
    # Add app settings file.
    app_name = VizborCLI::AppState.add_settings
    puts "2.Added settings file for your application -> " \
         "src/#{app_name}/settings.cr".colorize.fore(:yellow).mode(:bold)
    puts "  If necessary, correct the `app_name` parameter."
      .colorize.fore(:blue).mode(:bold)
    # Add import of the `Vizbor` library to the main project file.
    main_file : String = File.read("src/#{app_name}.cr")
    File.write("src/#{app_name}.cr", %Q(require "vizbor"\n\n#{main_file}))
    puts %Q(Added import `require "vizbor"` into main project file -> src/#{app_name}.cr)
      .colorize.fore(:yellow).mode(:bold)
    # Successful completion.
    puts "Done".colorize.fore(:green).mode(:bold)
    exit 0
  end

  private def add_service(name : String)
    exit 0
  end

  private def delete_service(name : String)
    exit 0
  end

  private def restore_access(username : String)
    exit 0
  end
end
