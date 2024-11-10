# frozen_string_literal: true

require 'io/console'
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
      @menu = [
        { normal: ' ▢ Organize episodes?', highlight: " \e[4m▣ Organize episodes.\e[0m", command: 'Organizer',
          disabled: false },
        { normal: ' ▢ Watch random episodes?', highlight: " \e[4m▣ Watch random episodes.\e[0m", command: 'Random',
          disabled: false },
        { normal: ' ▢ Watch by playlist?', highlight: " \e[4m▣ Watch by playlist.\e[0m", command: 'Playlist',
          disabled: false }
      ]
      @msg = { success: "kewl!\n", fail: "lame!\n" }
    end

    def setup
      print_banner
      make_config if first_time?
      load_folder
    end

    def run
      setup
      display(@menu)
    end
  end
end

app = SouthSync::App.new
app.run
