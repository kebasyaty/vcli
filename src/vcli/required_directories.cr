module VizborCLI::RequiredDirectories
  extend self

  def add : Nil
    directories = {
      "lib/vcli/directories/assets"    => "assets",
      "lib/vcli/directories/config"    => "config",
      "lib/vcli/directories/templates" => "templates",
      "lib/vcli/directories/.vscode"   => ".vscode",
      "lib/vcli/directories/.github"   => ".github",
    }

    directories.each do |src_path, dest_path|
      FileUtils.cp_r(src_path, dest_path)
    end
  end
end
