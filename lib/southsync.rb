# frozen_string_literal: true

require 'io/console'
require 'nokolexbor'
require 'open-uri'
require 'yaml'
require 'fileutils'
require_relative 'southsync/config'
require_relative 'southsync/cli'
require_relative 'southsync/utilities'
require_relative 'southsync/organize'
require_relative 'southsync/scraper'

module SouthSync
  # Run Main Menu
  class App
    attr_reader :menu

    include CLI
    include Config

    def initialize
      @menu = [
        { text: 'Organize episodes', command: Organizer },
        { text: 'Watch random episodes', command: 'Random' },
        { text: 'Watch by playlist', command: 'Playlist' },
        { text: 'Search Quotes', command: 'Quotes' }
      ]
    end

    def run
      start_up
      selected_entry = Display.menu(menu: menu)
      exit unless selected_entry

      go_to(selected_entry)
    end

    private

    def start_up
      first_time? ? make_config : valid_folder?
    end

    def go_to(entry)
      cmd = entry.fetch(:command)
      cmd.new(self).run
    end
  end
end
