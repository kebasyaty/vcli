module VizborCLI::MainFile
  extend self

  def modify_main_file(app_name : String) : Nil
    main_file : String = File.read("src/#{app_name}.cr")
    import = "require \"./#{app_name}/settings\"\n" \
             "require \"./#{app_name}/services/**\"\n" \
             "require \"vizbor\"\n\n"
    File.write("src/#{app_name}.cr", "#{import}\n\n#{main_file}")
  end
end
