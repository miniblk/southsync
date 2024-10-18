# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'fileutils'

# Just generate dummy files with certain pattern
module DummyGenerator
  URL = 'https://en.wikipedia.org/wiki/List_of_South_Park_episodes'
  TEST_DIR = File.join(__dir__, 'files')

  class << self
    def generate
      FileUtils.mkdir_p(TEST_DIR) unless Dir.exist?(TEST_DIR)

      if Dir.empty?(TEST_DIR)
        seasons_data = fetch_data
        populate!(seasons_data)
      else
        puts Dir.entries(__dir__) - ['.', '..']
        entries = Dir.entries(TEST_DIR) - ['.', '..']
        entries.each do |entry|
          puts "└── #{entry}"
          sleep 0.1
        end
      end
    end

    private

    def random_choice
      [true, false].sample
    end

    def file_patterns
      {
        show_title: ['SP', 'South Park'],
        season: ['Season ', 'Season_', 'S'],
        episode: ['Episode ', 'Episode_', 'E'],
        quality: %w[1080p 720p],
        encoder: %w[blutuht hif5 djabc],
        codec: %w[x265 x264],
        seperator: ['_', '-', ' ', '.'].sample,
        extensions: ['.mkv', '.mp4', '.avi'].sample
      }
    end

    def build_files(season_number, ep_number, ep_title)
      file_name = []
      file_patterns.each do |k, v|
        next if %i[seperator extensions].include?(k)

        random_pattern = v.sample

        case k
        when :season then file_name << "#{random_pattern}#{season_number}"
        when :episode then file_name << "#{random_pattern}#{ep_number}(#{ep_title})"
        else
          file_name << random_pattern unless %i[quality encoder codec].include?(k) && random_choice
        end
      end
      file_name.join(file_patterns[:seperator]) + file_patterns[:extensions]
    end

    def populate!(seasons_data)
      seasons_data.each do |season, eps|
        eps.each do |ep_number, ep_title|
          test_files = build_files(season, ep_number, ep_title)
          puts "Generating #{test_files}"
          FileUtils.touch("#{TEST_DIR}/#{test_files}")
          sleep 0.1
        end
      end
    end

    def fetch_data
      data = {}
      episode_tables = load_page.css('table.wikiepisodetable')
      episode_tables.each do |table|
        next if table.previous_element.at('a').nil?

        season = table.previous_element.at('a').text.delete_prefix('South Park season ')
        data[season] = parse_tables(table) if [2, 5, 4, 3, 18].include?(season.to_i)
      end
      data
    end

    def parse_tables(table)
      episodes_data = {}
      table.css('tr')[1..].each do |row|
        columns = row.css('td, th')[1..2]
        episode_number = columns[0].text
        episode_title = columns[1].text.tr('\"', '')

        episodes_data[episode_number] = episode_title
      end
      episodes_data
    end

    def load_page
      Nokogiri::HTML(URI.parse(DummyGenerator::URL).open.read)
    rescue StandardError => e
      puts "Something went wrong :( \n#{e}"
    end
  end
end

DummyGenerator.generate
