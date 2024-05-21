module VizborCLI::RequiredDirectories
  extend self

  # Copy folders to the project root.
  def add : Nil
    directories = {
      "lib/vcli/directories/.github"   => ".github",
      "lib/vcli/directories/.vscode"   => ".vscode",
      "lib/vcli/directories/assets"    => "assets",
      "lib/vcli/directories/config"    => "config",
      "lib/vcli/directories/templates" => "templates",
    }

    directories.each do |src_path, dest_path|
      FileUtils.cp_r(src_path, dest_path)
    end
  end
end
