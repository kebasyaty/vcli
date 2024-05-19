module VizborCLI::MainFile
  extend self

  def modify_main_file(app_name : String) : Nil
    path = Path.new("src/#{app_name}.cr")
    main_file : String = File.read(path)
    check_main_file(main_file)
    arr = main_file.split("\n")
    import = "require \"vizbor\"\n" \
             "require \"./#{app_name}/settings\"\n" \
             "require \"./#{app_name}/services/**\"\n\n"
    arr[0] = import
    arr[4] = "  # Start Web Server.\n" \
             "  Vizbor::Server.run"
    File.write(path, arr.join)
  end

  private def check_main_file(main_file : String) : Nil
    if main_file.empty?
      puts "The main project file must not be empty!"
      exit 1
    end
  end
end
