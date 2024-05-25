module VizborCLI::RequiredDirectories
  extend self

  # Copy folders to the project root.
  def add(app_name : String) : Nil
    directories = {
      "lib/vcli/directories/.github"       => ".github",
      "lib/vcli/directories/.vscode"       => ".vscode",
      "lib/vcli/directories/config"        => "config",
      "lib/vcli/directories/public"        => "public",
      "lib/vcli/directories/views"         => "views",
      "lib/vcli/directories/services"      => "src/#{app_name}/services",
      "lib/vcli/directories/middleware.cr" => "src/#{app_name}/middleware.cr",
      "lib/vcli/directories/routes.cr"     => "src/#{app_name}/routes.cr",
    }

    path = Path.new("src/#{app_name}")
    Dir.mkdir_p(path) unless Dir.exists?(path)

    directories.each do |src_path, dest_path|
      FileUtils.cp_r(src_path, dest_path)
    end
  end
end
