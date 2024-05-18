module VCLI::AppState
  extend self
  ALPHANUMERIC_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  ADDITIONAL_SYMBOLS = "-._!`'#%&,:;<>=@{}~$()*+/?[]^|"

  def add_settings : String
    app_name = YAML.parse(File.read("shard.yml"))["name"].as_s
    settings = "# Settings for your web application.\n" \
               "module Vizbor::Settings\n" \
               "  # If true,\n" \
               "  # an exception page is rendered when an exception is raised which provides a\n" \
               "  # lot of useful information for debugging.\n" \
               "  class_getter? debug : Bool = true\n" \
               "  # Maximum 44 characters.\n" \
               "  class_getter app_name : String = \"#{app_name.gsub("-") { "_" }.camelcase}\"\n" \
               "  # Match regular expression: /^[a-zA-Z0-9]{16}$/\n" \
               "  # To generate a key (This is not an advertisement): https://randompasswordgen.com/\n" \
               "  class_getter unique_app_key : String = \"#{generate_unique_app_key}\"\n" \
               "  # Maximum 60 characters.\n" \
               "  class_getter! database_name : String\n" \
               "  # https://github.com/crystal-i18n/i18n\n" \
               "  class_getter default_locale : Symbol = :en\n" \
               "  # Domain names.\n" \
               "  class_getter domain_name : String = @@debug ? \"0.0.0.0\" : \"www.your-site-name.net\"\n" \
               "  # Port for test server.\n" \
               "  class_getter port : Int32 = 3000\n" \
               "  # Static File Options.\n" \
               "  # https://kemalcr.com/guide/\n" \
               "  # Example: {\"gzip\" => true, \"dir_listing\" => false}\n" \
               "  class_getter! static_file_options : Hash(String, Bool)\n" \
               "  # Disable Static Files.\n" \
               "  class_getter? disable_static_files : Bool = false\n" \
               "  # Using Reuse Port for Multiple Kemal Processes.\n" \
               "  # https://kemalcr.com/cookbook/reuse_port/\n" \
               "  class_getter? server_reuse_port : Bool = false\n" \
               "  # Use Logging?\n" \
               "  # https://kemalcr.com/guide/\n" \
               "  # You can add logging statements to your code:\n" \
               "  # Example: Log.info { \"Log message with or without embedded \#{variables}\" }\n" \
               "  class_getter? use_logging : Bool = true\n" \
               "  # Maximum upload content size for a web form.\n" \
               "  # 1 MB = 1048576 Bytes (in binary).\n" \
               "  # Default: 1048576 * 2 = 2097152 = 2 MB\n" \
               "  class_getter max_upload_size : Int32 = 2097152\n" \
               "  # Security\n" \
               "  # To generate a key (This is not an advertisement): https://randompasswordgen.com/\n" \
               "  # Minimum 64 characters.\n" \
               "  class_getter secret_key : String = \"#{generate_secret_key}\"\n" \
               "end\n"
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
