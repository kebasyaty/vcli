module VizborCLI::RequiredDirectories
  extend self

  # Copy folders to the project root.
  def add : Nil
    directories = {
      "lib/vcli/directories/.github"    => ".github",
      "lib/vcli/directories/.vscode"    => ".vscode",
      "lib/vcli/directories/config"     => "config",
      "lib/vcli/directories/public"     => "public",
      "lib/vcli/directories/services"   => "services",
      "lib/vcli/directories/views"      => "views",
      "lib/vcli/directories/middleware" => "middleware",
      "lib/vcli/directories/routes"     => "routes",
    }

    directories.each do |src_path, dest_path|
      FileUtils.cp_r(src_path, dest_path)
    end
  end
end
