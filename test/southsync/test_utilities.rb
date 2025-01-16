# frozen_string_literal: true

require 'test_helper'

class TestUtilities < Minitest::Test
  include SouthSync::Utilities
  include SouthSync::Config
  include DummyFiles

  def setup
    DummyFiles.generate_files
    @temp_dir = DummyFiles::TMP_DIR
    @config_path = File.join('./test/', 'test_config.yml')
    config = { 'show_location' => @temp_dir }

    File.open(@config_path, 'w+') { |file| file.write(config.to_yaml) }

    SouthSync::Config.send(:remove_const, 'CONFIG_FILE') if SouthSync::Config.const_defined?('CONFIG_FILE')
    SouthSync::Config.send(:const_set, 'CONFIG_FILE', @config_path)

    @organizer = SouthSync::Organizer.new(Object.new)
  end

  def teardown
    SouthSync::Config.send(:remove_const, 'CONFIG_FILE')
    DummyFiles.cleanup
    FileUtils.rm(@config_path)
  end

  def test_replace_episode_title_for_a_non_exist_episode
    filename = 'South Park Season_8 E55 1080p hif5 x264.avi'
    file = fetch_data(filename)
    file[:data][:pattern] = 'Season[season-number]-Episode-[episode-number]-[episode-title]'
    result = replace(file[:data])

    assert_nil result, 'Expected a nil result'
  end

  def test_replace_episode_title_for_a_non_exist_season
    filename = 'South Park Season_88 E5 1080p hif5 x264.avi'
    file = fetch_data(filename)
    file[:data][:pattern] = 'Season[season-number]-Episode-[episode-number]-[episode-title]'
    result = replace(file[:data])

    assert_nil result, 'Expected a nil result'
  end

  def test_replace_with_a_invalid_filename
    filename = 'South Park 0805.mp4'
    file = fetch_data(filename)
    assert_raises(NoMethodError) do
      file[:data][:pattern] = '[show-title] - Episode-[episode-number]'
      replace(file[:data])
    end
  end

  def test_replace_by_pattern_with_episode_title
    filename = 'South Park Season8 Episode5 1080p.mp4'
    file = fetch_data(filename)
    file[:data][:pattern] = '[show-title] - S[season-number]E[episode-number]([episode-title])'
    result = replace(file[:data])

    assert_equal 'South Park - S08E05(Awesom-O).mp4', result
  end

  def test_replace_by_pattern_without_episode_title
    filename = 'South Park Season_8 E5 1080p hif5 x264.avi'
    file = fetch_data(filename)
    file[:data][:pattern] = 'Episode-[episode-number]'
    result = replace(file[:data])

    assert_equal 'Episode-05.avi', result
  end

  def test_valid_files_is_returns_array
    assert_kind_of Array, valid_files
  end

  def test_valid_files_with_no_valid_extensions
    DummyFiles.remove_valid_files
    assert_empty valid_files, 'Expected empty if there are no valid files'
  end

  def test_extract_number
    filename = 'South Park Season_8 E5 1080p hif5 x264.avi'

    season = extract_number[:season].call(filename)
    episode = extract_number[:episode].call(filename)

    assert_equal '8', season
    assert_equal '5', episode
  end

  def test_missing_both_numbers
    filename = 'South Park 1 Episode season twenty.mp4'

    season = extract_number[:season].call(filename)
    episode = extract_number[:episode].call(filename)

    assert_nil episode, 'Expected episode number to be nil'
    assert_nil season, 'Expected season number to be nil'
  end

  def test_missing_episode_number
    filename = 'SP_S08_1080p_hif5_x264.mp4'

    episode = extract_number[:episode].call(filename)

    assert_nil episode, 'Expected episode number to be nil'
  end

  def test_missing_season_number
    filename = 'SP e5 1080p hif5 x264.mp4'

    season = extract_number[:season].call(filename)

    assert_nil season, 'Expected season number to be nil'
  end
end
