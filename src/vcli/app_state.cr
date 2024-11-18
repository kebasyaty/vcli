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
  # WARNING: Maximum 60 characters.
  # WARNING: Match regular expression: /^[a-zA-Z][-_a-zA-Z0-9]{0,59}$/
  # NOTE: Format for development and tests: test_<key>
  # NOTE: To generate a key (This is not an advertisement): https://randompasswordgen.com/
  class_getter database_name : String = "test_#{generate_unique_key}"
  # NOTE: https://github.com/crystal-i18n/i18n
  class_getter default_locale : String = "en"
  # Security
  # WARNING: Minimum 64 characters.
  class_getter secret_key : String = "#{Random::Secure.hex(64)}"

  # The default administrator e -mail, for production.
  # WARNING: Maximum 320 characters.
  class_getter admin_prod_email = "???" # <----------------------------- replace
  # The default administrator e -mail, for development.
  # WARNING: Maximum 320 characters.
  class_getter admin_dev_email = "no_reply@email.net"
  # The default administrator password, for production.
  # WARNING: Number of characters: max=256, min=8.
  # NOTE: To generate a key (This is not an advertisement): https://randompasswordgen.com/
  class_getter admin_prod_pass = "???" # <------------------------------ replace
  # The default administrator password, for development.
  # WARNING: Number of characters: max=256, min=8.
  class_getter admin_dev_pass = "12345678"

  # URI Scheme
  def scheme : String
    "http%{s}" % {s: !@@debug ? "s" : ""}
  end

  # URI Port
  def port : Int32
    3000
  end

  # URI Host - Domain name
  def host : String
    if !@@debug
      "www.your-domain-name.net" # <------------------------------------ replace
    else
      "localhost" + ":" + port.to_s
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

  private def generate_unique_key : String
    result : String = ""
    # Shuffle symbols in random order.
    shuffled_chars : Array(String) = ALPHANUMERIC_CHARS.split("").shuffle!
    chars_count : Int32 = shuffled_chars.size - 1
    size : Int32 = 16
    size.times do
      result += shuffled_chars[Random.rand(chars_count)]
    end
    result
  end
end
