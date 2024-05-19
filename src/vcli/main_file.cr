module VizborCLI::MainFile
  extend self

  def modify_main_file(app_name : String) : Nil
    main_file : String = File.read("src/#{app_name}.cr")
    main_file_arr = main_file.split("\n")
    import = "require \"vizbor\"\n" \
             "require \"./#{app_name}/settings\"\n" \
             "require \"./#{app_name}/services/**\"\n\n"
    main_file_arr[0] = import
    main_file_arr[4] = "  # Start Web Server.\n" \
                       "  Vizbor::Server.run"
    File.write("src/#{app_name}.cr", "#{import}\n\n#{main_file}")
  end
end
