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

  private def parse_args(args)
    OptionParser.parse(args) do |parser|
      parser.on("-v", "--version", "Print version") { print_version }
      parser.on("-h", "--help", "Show this help") { print_help(parser) }
      parser.on("--init APP_NAME", "Initialize project") { |app_name| init_project(app_name) }
      parser.on("--add NAME", "Add a new service") { |name| add_service(name) }
      parser.on("--delete NAME", "Delete service") { |name| delete_service(name) }
      parser.on(
        "--restore TOKEN",
        "Restore access to admin panel",
      ) { |token| restore_access(token) }
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

  private def init_project(db_app_name : String)
    # NOTE: db_app_name - will be used for the database name + unique_app_key
    #
    if db_app_name.size > 44
      STDERR.puts "ERROR: APP_NAME - Maximum 44 characters."
        .colorize.fore(:red).mode(:bold)
      exit 1
    end
    unless /^[a-zA-Z][-_a-zA-Z0-9]{0,43}$/.matches?(db_app_name)
      STDERR.puts "ERROR: APP_NAME - " \
                  "Doesn't match regular expression /^[a-zA-Z][-_a-zA-Z0-9]{0.43}$/"
        .colorize.fore(:red).mode(:bold)
      exit 1
    end
    #
    puts "Start project initialization:".colorize.fore(:green).mode(:bold)
    # Add an Mongo options file.
    VizborCLI::MongoOptions.add_mongo_options
    puts "1.Added Mongo driver options file -> config/mongo/options.yml"
      .colorize.fore(:yellow).mode(:bold)
    # Add app settings file.
    app_name = VizborCLI::AppState.add_settings(db_app_name)
    puts "2.Added settings file for your application -> " \
         "src/#{app_name}/settings.cr".colorize.fore(:yellow).mode(:bold)
    puts "  If necessary, correct the `app_name` parameter."
      .colorize.fore(:blue).mode(:bold)
    # Add the main service `Admin`.
    # ...
    puts "3.Added the main service `Admin` -> src/#{app_name}/services/admin"
      .colorize.fore(:yellow).mode(:bold)
    # Add `require "vizbor"` to the main project file.
    main_file : String = File.read("src/#{app_name}.cr")
    File.write("src/#{app_name}.cr", %Q(require "vizbor"\n\n#{main_file}))
    puts %Q(4.Added `require "vizbor"` to the main project file -> src/#{app_name}.cr)
      .colorize.fore(:yellow).mode(:bold)
    # Successful completion.
    puts "Done".colorize.fore(:green).mode(:bold)
    exit 0
  end

  private def add_service(name : String)
    puts name
    exit 0
  end

  private def delete_service(name : String)
    puts name
    exit 0
  end

  private def restore_access(token : String)
    # token - username or email
    puts token
    exit 0
  end
end
