module VizborCLI::RequiredDirectories
  extend self

  def add : Nil
    directories = {
      "assets.zip"    => "https://raw.githubusercontent.com/kebasyaty/vizbor-assets/main/assets.zip",
      "config.zip"    => "https://raw.githubusercontent.com/kebasyaty/vizbor-assets/main/config.zip",
      "templates.zip" => "https://raw.githubusercontent.com/kebasyaty/vizbor-assets/main/templates.zip",
    }

    directories.each do |path, link|
      # Download zip archive
      download_zip(link, path)
      # Unpack zip archive.
      unpack_zip(path)
    end
  end

  private def download_zip(download_link : String, save_path : String) : Nil
    HTTP::Client.get(download_link) do |response|
      unless response.status.success?
        raise "error response"
      end
      File.open(save_path, "w") { |file_io| IO.copy response.body_io, file_io }
    end
  end

  private def unpack_zip(zip_file : String) : Nil
    Compress::Zip::File.open(zip_file) do |file|
      file.entries.each do |entry|
        if entry.file?
          dir_path = File.dirname(entry.filename)
          Dir.mkdir_p(dir_path) unless Dir.exists?(dir_path)
          entry.open do |io|
            File.write(entry.filename, io.gets_to_end)
          end
        end
      end
    end
    File.delete(zip_file)
  end
end
