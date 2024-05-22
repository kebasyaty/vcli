module VizborCLI::AppState
  extend self
  ALPHANUMERIC_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  # Collect a file with settings and add it to the project.
  def add(db_app_name : String) : String
    app_name = YAML.parse(File.read("shard.yml"))["name"].as_s
    settings = %Q(# Settings for your web application.
module Vizbor::Settings
  extend self
  # If true,
  # an exception page is rendered when an exception is raised which provides a
  # lot of useful information for debugging.
  class_getter? debug : Bool = true
  # Maximum 44 characters.
  class_getter app_name : String = "#{db_app_name}"
  # Match regular expression: /^[a-zA-Z0-9]{16}$/
  # To generate a key (This is not an advertisement): https://randompasswordgen.com/
  class_getter unique_app_key : String = "#{generate_unique_app_key}"
  # Maximum 60 characters.
  # Hint: If the line is empty, the name will be generated automatically.
  class_getter database_name : String = ""
  # https://github.com/crystal-i18n/i18n
  class_getter default_locale : Symbol = :en
  # Domain names.
  class_getter domain_name : String = @@debug ? "0.0.0.0" : "www.your-site-name.net"
  # Port for test server.
  class_getter port : Int32 = 3000
  # Static File Options.
  # https://kemalcr.com/guide/
  # Example: {"gzip" => true, "dir_listing" => false}
  class_getter! static_file_options : Hash(String, Bool)
  # Disable Static Files.
  class_getter? disable_static_files : Bool = false
  # Using Reuse Port for Multiple Kemal Processes.
  # https://kemalcr.com/cookbook/reuse_port/
  class_getter? server_reuse_port : Bool = false
  # Use Logging?
  # https://kemalcr.com/guide/
  # You can add logging statements to your code:
  # Example: Log.info { "Log message with or without embedded \#{variables}" }
  class_getter? use_logging : Bool = true
  # Security
  # To generate a key (This is not an advertisement): https://randompasswordgen.com/
  # Minimum 64 characters.
  class_getter secret_key : String = "#{Random::Secure.hex(64)}"

  def app_url : String
    if @@debug
      "http://" + @@domain_name + @@port.to_s
    else
      "https://" + @@domain_name
    end
  end
end
)
    path = Path.new("src/#{app_name}")
    Dir.mkdir_p(path) unless Dir.exists?(path)
    File.write(path / "settings.cr", settings) unless File.file?(path)
    app_name
  end

  private def generate_unique_app_key : String
    result : String = ""
    # Shuffle symbols in random order.
    shuffled_chars : Array(String) = ALPHANUMERIC_CHARS.split("").shuffle
    chars_count : Int32 = shuffled_chars.size - 1
    size : Int32 = 16
    size.times do
      result += shuffled_chars[Random.rand(chars_count)]
    end
    result
  end
end
