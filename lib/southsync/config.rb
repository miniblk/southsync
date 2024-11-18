# frozen_string_literal: true

module SouthSync
  # Config stuff goes here
  module Config
    ROOT_DIR = File.expand_path('../..', __dir__)
    CONFIG_FILE = File.join(ROOT_DIR, '/config/config.yml')

    def first_time?
      true unless File.exist?(CONFIG_FILE) && load_config['show_location']
    end

    def folder_path
      ask('Enter folder location...').strip
    end

    def count_files(path)
      extensions = ['.mkv', '.mp4', '.avi']
      entries = Dir.entries(path)
      valid_files = entries.count { |entry| extensions.include?(File.extname(entry)) }

      puts "Found #{valid_files} video files / #{entries.count} files"
    end

    def load_folder
      full_path = File.expand_path(load_config['show_location'])
      loading_thread = Thread.new { loading_indicator(load_config['show_location']) }
      loading_thread.join(1)

      print Dir.exist?(full_path) ? @msg[:success] : @msg[:fail]
      count_files(full_path)

      Thread.kill(loading_thread)
      sleep 1
    rescue Errno::ENOENT => e
      puts "Error while loading files...\n#{e}"
      # still need to handle this later... should i ensure to rm config.yml?
    end

    def make_config
      config = { 'show_location' => folder_path }
      FileUtils.mkdir_p("#{ROOT_DIR}/config")
      config_file = File.open(CONFIG_FILE, 'w+')
      config_file.write(config.to_yaml)
    rescue IOError => e
      puts "Error reading file: #{e.message}"
    ensure
      config_file&.close
    end

    def load_config
      YAML.safe_load(File.read(CONFIG_FILE), permitted_classes: [Symbol])
    rescue Errno::ENOENT => e
      puts "Error loading config file: #{e.message}"
    rescue Psych::SyntaxError, Psych::DisallowedClass => e
      puts "YAML parsing error: #{e.message}"
    end
  end
end
