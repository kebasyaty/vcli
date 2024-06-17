module VizborCLI::MainFile
  extend self

  def modify(app_name : String) : Nil
    path = Path.new("src/#{app_name}.cr")
    main_file : String = File.read(path)
    check_main_file(main_file, app_name)
    arr = main_file.split("\n")
    import = "require \"vizbor\"\n" \
             "require \"./#{app_name}/settings\"\n" \
             "require \"./#{app_name}/globals/**\"\n" \
             "require \"./#{app_name}/middleware/**\"\n" \
             "require \"./#{app_name}/renderer/**\"\n" \
             "require \"./#{app_name}/services/**\"\n"
    arr[0] = import
    arr[4] = "  Vizbor::WebServer.run"
    File.write(path, arr.join("\n") + "\n")
  end

  private def check_main_file(main_file : String, app_name : String) : Nil
    if main_file.empty?
      STDERR.puts "ERROR: The main project file must not be empty! -> " \
                  "src/#{app_name}.cr"
        .colorize.fore(:red).mode(:bold)
      exit 1
    end
  end
end
