# frozen_string_literal: true

module SouthSync
  # Utility stuff mostly used by Organizer... for now
  module Utilities
    include Config

    def extract_number
      {
        episode: ->(str) { str.match(/(?:episode|e|ep)[\s_-]?(\d{1,2})/i)&.[](1) },
        season: ->(str) { str.match(/(?:season|s)[\s_-]?(\d{1,2})/i)&.[](1) }
      }
    end

    def replace(file_data = {})
      replacements = {
        '[season-number]' => file_data[:season].to_s.rjust(2, '0'),
        '[episode-number]' => file_data[:episode].to_s.rjust(2, '0'),
        '[show-title]' => 'South Park'
      }
      replacements['[episode-title]'] = fetch_title(file_data) if file_data[:pattern].include?('episode-title')
      return if replacements.values.any?(&:nil?)

      "#{file_data[:pattern].gsub(/\[.*?\]/, replacements)}#{file_data[:extension]}"
    end

    def fetch_title(data)
      episode_title = FetchTitle.new(data)
      episode_title.crawl
      error_msg = "[!] #{episode_title.errors}"

      return error_msg if episode_title.errors?

      episode_title.output
    end

    def valid_files
      all_files[0].map { |file| fetch_data(file) }.compact
    end

    def group_files_by_season
      valid_files.group_by do |file|
        file.fetch(:data)[:season]
      end
    end

    def fetch_data(file)
      data = {
        season: extract_number[:season].call(file).to_i,
        episode: extract_number[:episode].call(file).to_i,
        extension: File.extname(file)
      }
      return if data[:season].zero? || data[:episode].zero?

      { filename: file, data: data }
    end
  end
end
