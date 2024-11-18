# frozen_string_literal: true

require 'io/console'
require 'yaml'
require 'fileutils'
require_relative 'southsync/cli'
require_relative 'southsync/config'
require_relative 'southsync/organize'

module SouthSync
  # Entry
  class App
    include CLI
    include Config

    def initialize
      @menu = [
        { text: 'Organize episodes', command: Organizer },
        { text: 'Watch random episodes', command: 'Random' },
        { text: 'Watch by playlist', command: 'Playlist' },
        { text: 'Search Quotes', command: 'Quotes' }
      ]
      @msg = { success: "kewl!\n", fail: "lame!\n" }
      @header_title = 'SouthSync'
    end

    def setup
      make_config if first_time?
      load_folder
    end

    def swap_menu(command)
      cmd = @menu[command][:command].new(@menu[command][:text])
      cmd.run
    end

    def run
      setup
      command_class = display(@menu, @header_title)

      swap_menu(command_class)
    end
  end
end
