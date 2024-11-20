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
        { text: 'S08E5(Awesom-O).mkv', pattern: 'S[season-number]E[episode-number]([episode-title])' },
        { text: 'Episode-5.mkv', pattern: 'Episode-[episode-number]' },
        { text: 'S08E05.mkv', pattern: 'S[season-number]E[episode-number]' },
        { text: 'Episode-5(Awesom-O).mkv', pattern: 'Episode-[episode-number]([episode-title])' },
        { text: 'Custom Pattern', pattern: 'Custom Pattern' }
      ]
      @data = {}
    end

    def run
      selected = display(@menu, @header_title)
      season_folders = list_files.group_by { |file| extract_number[:season].call(file) }
      organize_it!(season_folders, @menu[selected][:pattern])
    end

    def list_files
      extensions = ['.mkv', '.mp4', '.avi']
      files = Dir.entries(@base_dir) - ['.', '..']
      files.select { |file| extensions.include?(File.extname(file)) }
    end

    def extract_number
      {
        episode: ->(str) { str.match(/(?:episode|e|ep)[\s_-]?(\d{1,2})/i)[1] },
        season: ->(str) { str.match(/(?:season|s)[\s_-]?(\d{1,2})/i)[1] }
      }
    end

    def replace_by(pattern, file_data = {})
      replacements = {
        '[season-number]' => file_data[:season].rjust(2, '0'),
        '[episode-number]' => file_data[:episode].rjust(2, '0'),
        '[episode-title]' => FetchTitle.new(file_data).crawl
      }
      pattern.gsub(/\[.*?\]/, replacements)
    end

    def organize_it!(folders, pattern)
      folders.each do |season, episodes|
        path = "#{@base_dir}/Season #{season}"
        FileUtils.mkdir_p(path)
        episodes.each do |ep|
          episode = extract_number[:episode].call(ep)
          new_filename = replace_by(pattern, { episode: episode, season: season }) + File.extname(ep)
          FileUtils.mv "#{@base_dir}/#{ep}", "#{path}/#{new_filename}"
          display_tree(@base_dir)
        end
      end
    end
  end
end
