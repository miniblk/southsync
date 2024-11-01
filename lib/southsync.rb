# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require_relative 'southsync/cli'

# local_path = config['local_path']
ROOT_DIR = File.expand_path('..', __dir__)
CONFIG_FILE = File.join(ROOT_DIR, '/config/config.yml')

module SouthSync
  # Entry
  class App
    include CLI

    def initialize
      @main_menu = [
        { normal: '▢ Organize episodes?', highlight: "\e[4m▣ Organize episodes\e[0m", command: 'Organizer' },
        { normal: '▢ Watch random episodes?', highlight: "\e[4m▣ Watch random episodes\e[0m" },
        { normal: '▢ Watch by playlist?', highlight: "\e[4m▣ Watch by playlist\e[0m" }
      ]
      @msg = ''
    end

    def run
      print BANNER

      make_config if first_time?

      scanning_folder
      # since already a config, start to load it, check the directory
      # is it legit? is it contains entries with certain video extensions?
    end

    private

    def first_time?
      true unless File.exist?(CONFIG_FILE) && load_config['show_location']
    end

    def folder_path
      ask('Enter folder location...')
    end

    def scanning_folder
      puts 'scanning with spinner...'
    end

    def make_config
      FileUtils.mkdir_p("#{ROOT_DIR}/config")
      config = { 'show_location' => folder_path }
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

app = SouthSync::App.new
app.run
