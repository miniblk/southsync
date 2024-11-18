# frozen_string_literal: true

module SouthSync
  # Organize stuff goes here
  class Organizer
    include CLI
    include Config

    def initialize(title)
      @header_title = title
      @base_dir = load_config['show_location']
      @menu = [
        { text: 'Episode-5.mkv', pattern: 'Episode-[episode-number]' },
        { text: 'S08E05.mkv', pattern: 'S[season-number]E[episode-number]' },
        { text: 'Episode-5(Awesom-O).mkv', pattern: 'Episode-[episode-number]([episode-title])' },
        { text: 'Custom Pattern?', pattern: 'Custom Pattern' }
      ]
    end

    def list_files
      extensions = ['.mkv', '.mp4', '.avi']
      files = Dir.entries(@base_dir) - ['.', '..']
      files.select { |file| extensions.include?(File.extname(file)) }
    end

    def extract_number
      {
        episode: ->(str) { str.match(/(?:episode|e|ep)[\s_-]?(\d{1,2})/i)[1] },
        season: ->(str) { str.match(/(?:season|s)[\s_-]?(\d{1,2})/i)[1] },
        extension: ->(file) { File.extname(file) }
      }
    end

    def run
      selected = display(@menu, @header_title)
      puts @menu[selected][:pattern].inspect
    end
  end
end
