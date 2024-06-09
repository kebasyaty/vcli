module VizborCLI::Donors
  extend self

  # Copy folders to the project root.
  def add(app_name : String) : Nil
    donors = {
      "lib/vcli/donors/github"        => ".github",
      "lib/vcli/donors/vscode"        => ".vscode",
      "lib/vcli/donors/config"        => "config",
      "lib/vcli/donors/public"        => "public",
      "lib/vcli/donors/views"         => "views",
      "lib/vcli/donors/services"      => "src/#{app_name}/services",
      "lib/vcli/donors/middleware.cr" => "src/#{app_name}/middleware.cr",
      "lib/vcli/donors/routes.cr"     => "src/#{app_name}/routes.cr",
      "lib/vcli/donors/session.cr"    => "src/#{app_name}/session.cr",
    }

    path = Path.new("src/#{app_name}")
    Dir.mkdir_p(path) unless Dir.exists?(path)

    donors.each do |src_path, dest_path|
      FileUtils.cp_r(src_path, dest_path)
    end
  end
end
