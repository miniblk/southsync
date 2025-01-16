# frozen_string_literal: true

module SouthSync
  # Scraper stuff with command pattern
  class Scraper
    attr_accessor :errors, :input, :output

    WIKI_URL = 'https://en.wikipedia.org/wiki/List_of_South_Park_episodes'
    FANDOM_URL = 'https://southpark.fandom.com/wiki/Portal:Scripts'
    COLLECTIONS_URL = 'https://www.southparkstudios.com/collections'

    def initialize(input = {})
      @errors = []
      @output = nil
      @input = input
    end

    def load_page(url)
      Nokogiri::HTML(URI.parse(url).open.read)
    rescue StandardError => e
      errors << "Failed to load page: #{e.message}"
      nil
    end

    def crawl
      raise NotImplementedError, "#{self.class} lacks '#{__method__}' method implementation"
    end

    def errors?
      @errors.any?
    end
  end

  # Crawl episode-title from wikipedia
  class FetchTitle < Scraper
    def crawl
      page = load_page(WIKI_URL)
      return unless page

      @output ||= episode_data_from_wiki(page)
    rescue StandardError => e
      errors << "Error: #{e.message}"
      nil
    end

    private

    def episode_data_from_wiki(page)
      episode_tables = page.css('table.wikiepisodetable')

      return if @input[:season].to_i > episode_tables.count

      episode_tables.each do |table|
        season = extract_season(table)
        next unless season.eql? @input[:season]

        return parse_tables(table)
      end
    end

    def extract_season(table)
      link = table.previous_element.at('a')
      link&.text&.delete_prefix('South Park season ')
    end

    def extract_episode(columns)
      number = columns[0].text.strip
      title = columns[1].at('a').text.tr('\"', '')
      [number, title]
    end

    def parse_tables(table)
      rows = table.css('tr')[1..]
      return if @input[:episode].to_i > rows.count

      rows.each do |row|
        columns = row.css('td, th')[1..2]
        episode_number, episode_title = extract_episode(columns)
        return episode_title if episode_number.eql? @input[:episode]
      end
    end
  end

  # Crawl scripts from fandom then save to a csv
  class FetchScript < Scraper
    def make_csv; end
    def crawl; end
  end

  # Crawl playlist from homepage
  class FetchPlaylist < Scraper
    def make_csv; end
    def crawl; end
  end
end
