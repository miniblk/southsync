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
      @output = episode_data_from_wiki
    rescue StandardError => e
      errors << e
    end

    private

    def episode_data_from_wiki
      data = nil
      episode_tables = load_page(WIKI_URL).css('table.wikiepisodetable')
      episode_tables.each do |table|
        next if table.previous_element.at('a').nil?

        season = table.previous_element.at('a').text.delete_prefix('South Park season ')
        data = parse_tables(table) if season.eql? @input[:season]
      end
      data
    end

    def parse_tables(table)
      table.css('tr')[1..].each do |row|
        columns = row.css('td, th')[1..2]
        episode_number = columns[0].text
        episode_title = columns[1].text.tr('\"', '')
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
