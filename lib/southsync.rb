# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require_relative 'southsync/cli'
require_relative 'southsync/config'

module SouthSync
  # Entry
  class App
    include CLI
    include Config

    def initialize
      @main_menu = [
        { normal: '▢ Organize episodes?', highlight: "\e[4m▣ Organize episodes\e[0m", command: 'Organizer' },
        { normal: '▢ Watch random episodes?', highlight: "\e[4m▣ Watch random episodes\e[0m" },
        { normal: '▢ Watch by playlist?', highlight: "\e[4m▣ Watch by playlist\e[0m" }
      ]
      @msg = { success: "kewl!\n", fail: "lame!\n" }
    end

    def setup
      make_config if first_time?
      load_folder
    end

    def run
      print_banner
      setup
    end
  end
end

app = SouthSync::App.new
app.run
