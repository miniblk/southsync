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
      Nokolexbor::HTML(URI.parse(url).open.read)
    rescue StandardError => e
      errors << "(•̆_•̆)?: #{e.message}"
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
      tables = page.css('table.wikiepisodetable')
      return if @input[:season] > 26

      season_table = find_season_table(tables)
      @output = find_episode_title(season_table)
    rescue StandardError => e
      errors << "(╯°□°)╯︵ ┻━┻: #{e.message}"
      nil
    end

    private

    def find_episode_title(table)
      rows = table.css('tr')[1..]
      rows.select do |row|
        columns = row.css('td, th')[1..2]
        ep_number = columns[0].text.strip
        ep_title = columns[1].at('a').text.tr('\"', '')
        return ep_title if ep_number == @input[:episode].to_s
      end
    end

    def find_season_table(tables)
      tables.select do |table|
        season_link = table.xpath('preceding::a[1]')
        season_number = season_link&.text&.delete_prefix('South Park season ')

        return table if input[:season].to_s == season_number
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
