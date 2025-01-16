# frozen_string_literal: true

module SouthSync
  # Config stuff goes here
  module Config
    ROOT_DIR = File.expand_path('../..', __dir__)
    CONFIG_FILE = File.join(ROOT_DIR, '/config/config.yml')
    EXTENSIONS = ['.mkv', '.mp4', '.avi'].freeze

    def first_time?
      true unless File.exist?(CONFIG_FILE) && load_config
    end

    def base_dir
      load_config['show_location']
    end

    def make_config
      folder_path = CLI::Input.ask('Enter folder location...').strip
      exit unless valid_folder?(folder_path)

      config = { 'show_location' => folder_path }
      FileUtils.mkdir_p("#{ROOT_DIR}/config")
      File.open(CONFIG_FILE, 'w+') do |file|
        file.write(config.to_yaml)
      end
    rescue IOError => e
      puts "\n[!] Error reading file: #{e.message}"
    end

    def load_config
      YAML.safe_load(File.read(CONFIG_FILE), permitted_classes: [Symbol])
    rescue Errno::ENOENT => e
      puts "\n[!] Error while loading config file: #{e.message}"
    rescue Psych::SyntaxError, Psych::DisallowedClass => e
      puts "YAML parsing error: #{e.message}"
    end

    def valid_folder?(path = base_dir)
      files_range = all_files(path).map(&:size)
      CLI::Display.spin(files_range)
      print "...kewl!\n"
      sleep 1
      true
    rescue Interrupt, Errno::ENOENT, Errno::ENOTDIR => e
      puts "\n[Lame!] Error while loading files...\n#{e}"
      false
    end

    def all_files(path = base_dir)
      full_path = File.expand_path(path)
      entries = Dir.entries(full_path) - ['.', '..']
      files = entries.select { |entry| File.file?(File.join(full_path, entry)) }

      video_files = files.select { |entry| EXTENSIONS.include?(File.extname(entry)) }
      [video_files, files]
    rescue Errno::ENOENT => e
      puts "[!] #{e.message}"
      exit
    end
  end
end
