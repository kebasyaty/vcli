module VizborCLI::AppState
  extend self
  ALPHANUMERIC_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  ADDITIONAL_SYMBOLS = "-._!`'#%&,:;<>=@{}~$()*+/?[]^|"

  def add_settings(camelcase_app_name : String) : String
    app_name = YAML.parse(File.read("shard.yml"))["name"].as_s
    settings = "# Settings for your web application.
module Vizbor::Settings
  # If true,
  # an exception page is rendered when an exception is raised which provides a
  # lot of useful information for debugging.
  class_getter? debug : Bool = true
  # Maximum 44 characters.
  class_getter app_name : String = \"#{camelcase_app_name}\"
  # Match regular expression: /^[a-zA-Z0-9]{16}$/
  # To generate a key (This is not an advertisement): https://randompasswordgen.com/
  class_getter unique_app_key : String = \"#{generate_unique_app_key}\"
  # Maximum 60 characters.
  class_getter! database_name : String
  # https://github.com/crystal-i18n/i18n
  class_getter default_locale : Symbol = :en
  # Domain names.
  class_getter domain_name : String = @@debug ? \"0.0.0.0\" : \"www.your-site-name.net\"
  # Port for test server.
  class_getter port : Int32 = 3000
  # Static File Options.
  # https://kemalcr.com/guide/
  # Example: {\"gzip\" => true, \"dir_listing\" => false}
  class_getter! static_file_options : Hash(String, Bool)
  # Disable Static Files.
  class_getter? disable_static_files : Bool = false
  # Using Reuse Port for Multiple Kemal Processes.
  # https://kemalcr.com/cookbook/reuse_port/
  class_getter? server_reuse_port : Bool = false
  # Use Logging?
  # https://kemalcr.com/guide/
  # You can add logging statements to your code:
  # Example: Log.info { \"Log message with or without embedded \#{variables}\" }
  class_getter? use_logging : Bool = true
  # Maximum upload content size for a web form.
  # 1 MB = 1048576 Bytes (in binary).
  # Default: 1048576 * 2 = 2097152 = 2 MB
  class_getter max_upload_size : Int32 = 2097152
  # Security
  # To generate a key (This is not an advertisement): https://randompasswordgen.com/
  # Minimum 64 characters.
  class_getter secret_key : String = \"#{generate_secret_key}\"
  # Mongo Driver Options.
  # https://elbywan.github.io/cryomongo/Mongo/Client.html
  class_getter mongo_uri : String = \"mongodb://localhost:27017\"
  # https://elbywan.github.io/cryomongo/Mongo/Options.html
  class_getter mongo_options : Vizbor::Globals::MongoDriverOptions = {
    appname:                                  nil,
    auth_mechanism:                           nil,
    auth_mechanism_properties:                nil,
    auth_source:                              nil,
    compressors:                              nil,
    connect_timeout:                          nil, # 10.seconds
    direct_connection:                        nil,
    heartbeat_frequency:                      10.seconds,
    journal:                                  nil,
    local_threshold:                          15.milliseconds,
    max_idle_time:                            nil,
    max_pool_size:                            100,
    max_staleness_seconds:                    nil,
    min_pool_size:                            1,
    read_concern_level:                       nil,
    read_preference:                          nil,
    read_preference_tags:                     [] of String,
    replica_set:                              nil,
    retry_reads:                              true,
    retry_writes:                             true,
    server_selection_timeout:                 30.seconds,
    server_selection_try_once:                true,
    socket_timeout:                           nil,
    ssl:                                      nil,
    tls:                                      nil,
    tls_allow_invalid_certificates:           nil,
    tls_allow_invalid_hostnames:              nil,
    tls_ca_file:                              nil,
    tls_certificate_key_file:                 nil,
    tls_certificate_key_file_password:        nil,
    tls_disable_certificate_revocation_check: nil,
    tls_disable_ocsp_endpoint_check:          nil,
    tls_insecure:                             nil,
    w:                                        nil,
    wait_queue_timeout:                       nil,
    w_timeout:                                nil,
    zlib_compression_level:                   nil,
  }
end
"
    path = Path.new("src/#{app_name}")
    Dir.mkdir_p(path) unless Dir.exists?(path)
    File.write(path / "settings.cr", settings) unless File.file?(path)
    app_name
  end

  def generate_unique_app_key : String
    result : String = ""
    # Shuffle symbols in random order.
    shuffled_chars : Array(String) = ALPHANUMERIC_CHARS.split("").shuffle
    #
    chars_count : Int32 = shuffled_chars.size - 1
    size : Int32 = 16
    size.times do
      result += shuffled_chars[Random.rand(chars_count)]
    end
    result
  end

  def generate_secret_key : String
    result : String = ""
    # Shuffle symbols in random order.
    shuffled_chars : Array(String) = (ALPHANUMERIC_CHARS + ADDITIONAL_SYMBOLS).split("").shuffle
    #
    chars_count : Int32 = shuffled_chars.size - 1
    size : Int32 = 64
    size.times do
      result += shuffled_chars[Random.rand(chars_count)]
    end
    result
  end
end
