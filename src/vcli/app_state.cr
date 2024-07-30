module VizborCLI::AppState
  extend self
  ALPHANUMERIC_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  # Collect a file with settings and add it to the project.
  def add(app_name : String, db_app_name : String) : Nil
    settings = %Q(# Settings for your web application.
module Vizbor::Settings
  extend self

  module Kemal
    extend self
    # Static File Options.
    # NOTE: https://kemalcr.com/guide/
    # NOTE: Example: {"gzip" => true, "dir_listing" => false}
    class_getter! static_file_options : Hash(String, Bool)
    # Disable Static Files.
    class_getter? disable_static_files : Bool = false
    # Using Reuse Port for Multiple Kemal Processes.
    # NOTE: https://kemalcr.com/cookbook/reuse_port/
    class_getter? server_reuse_port : Bool = false
    # Use Logging?
    # NOTE: https://kemalcr.com/guide/
    # NOTE: You can add logging statements to your code:
    # NOTE: Example: Log.info { "Log message with or without embedded \#{variables}" }
    class_getter? use_logging : Bool = true
  end

  # If true,
  # an exception page is rendered when an exception is raised which provides a
  # lot of useful information for debugging.
  class_getter? debug : Bool = true
  # WARNING: Maximum 44 characters.
  class_getter app_name : String = "#{db_app_name}"
  # WARNING: Match regular expression: /^[a-zA-Z0-9]{16}$/
  # NOTE: To generate a key (This is not an advertisement): https://randompasswordgen.com/
  class_getter unique_app_key : String = "#{generate_unique_app_key}"
  # WARNING: Maximum 60 characters.
  # WARNING: If the line is empty, the name will be generated automatically.
  class_getter database_name : String = ""
  # NOTE: https://github.com/crystal-i18n/i18n
  class_getter default_locale : String = "en"
  # Security
  # WARNING: Minimum 64 characters.
  class_getter secret_key : String = "#{Random::Secure.hex(64)}"

  # Administrator production email.
  # WARNING: Maximum 320 characters.
  class_getter admin_prod_email = "???"
  # Administrator production password.
  # WARNING: Default number of characters: max = 256, min = 8
  # NOTE: To generate a key (This is not an advertisement): https://randompasswordgen.com/
  class_getter admin_prod_pass = "???"

  # URI Scheme
  def scheme : String
    if !@@debug
      "https"
    else
      "http"
    end
  end

  # URI Port
  def port : Int32
    3000
  end

  # URI Host - Domain name
  def host : String
    if !@@debug
      "www.your-site-name.net"
    else
      "127.0.0.1" + ":" + port.to_s
    end
  end

  # Application URL
  def app_url : String
    url : String = scheme + "://" + host
    url += ":" + port.to_s if @@debug
    url
  end
end
)
    path = Path.new("src/#{app_name}")
    Dir.mkdir_p(path) unless Dir.exists?(path)
    File.write(path / "settings.cr", settings) unless File.file?(path)
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
