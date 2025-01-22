# frozen_string_literal: true

module SouthSync
  # Organize stuff goes here
  class Organizer
    attr_reader :menu, :main_app

    include CLI
    include Utilities

    def initialize(main_app)
      @menu = [
        { text: 'Episode-5.mkv', pattern: 'Episode-[episode-number]' },
        { text: 'S08E5(Awesom-O).mkv', pattern: 'S[season-number]E[episode-number]([episode-title])' },
        { text: 'S08E05.mkv', pattern: 'S[season-number]E[episode-number]' },
        { text: 'Episode-5(Awesom-O).mkv', pattern: 'Episode-[episode-number]([episode-title])' },
        { text: 'Custom Pattern', pattern: 'custom' }
      ]
      @main_app = main_app
    end

    def run
      @selected = Display.menu(menu: menu, header: self.class.name) unless valid_files.empty?
      main_app.run if @selected.nil? # return to main menu

      pattern = @selected[:pattern]
      pattern = Input.ask('Enter your custom pattern...', :pattern).strip if pattern == 'custom'
      proceed?(pattern) ? organize(pattern) : @selected = nil || run
    end

    private

    def proceed?(pattern)
      first_file = valid_files.first
      first_file.fetch(:data)[:pattern] = pattern

      old_file = first_file.fetch(:filename)
      result = replace(first_file[:data])
      return Display.error(result, old_file) if result.include?('[!]')

      data = { pattern: pattern, lines: [old_file, result] }
      Display.preview(**data, header: __method__.to_s)
    end

    def organize(pattern)
      msg = pattern.include?('episode-title') ? "Fetching data... it'll take a while" : 'Running...'
      Display.render_content(footer: :any) do
        Display.box(msg, msg.length + 2)
        process_season(pattern)
      end
    rescue StandardError => e
      Text.dimmed_yellow e
    ensure
      main_app.run if Input.capture_input
    end

    def process_season(pattern)
      group_files_by_season.each do |season, episodes|
        path = "#{base_dir}/Season #{season}"
        FileUtils.mkdir_p(path)
        new_filenames = bulk_rename(episodes, path, pattern)
        Display.tree(dir: season, files: new_filenames)
      end
      Display.box('Done!', 7)
    end

    def duplication?(file)
      return unless File.exist?(file)

      Text.dimmed_yellow "┠ Skipping: File '#{file}' already exists."
      true
    end

    def bulk_rename(files, path, pattern)
      files.map do |file|
        data = file.fetch(:data)
        data[:pattern] = pattern
        new_filename = replace(data)

        target_path = "#{path}/#{new_filename}"
        next if duplication?(target_path)

        FileUtils.mv "#{base_dir}/#{file[:filename]}", target_path

        new_filename
      end
    end
  end
end
