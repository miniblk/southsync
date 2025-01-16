# frozen_string_literal: true

require 'fileutils'

# Generate dummy files for testing
module DummyFiles
  module_function

  FILE_PATTERNS = {
    show_title: ['SP', 'South Park'],
    season: ['Season ', 'Season_', 'S'],
    episode: ['Episode ', 'Episode_', 'E'],
    quality: %w[1080p 720p],
    encoder: %w[blutuht hif5 djabc],
    codec: %w[x265 x264],
    separator: ['_', '-', ' ', '.'],
    extensions: ['.srt', '.mkv', '.mp4', '.avi']
  }.freeze

  TEST_DIR = File.expand_path('..', __dir__)
  TMP_DIR = File.join(TEST_DIR, 'tmp')

  def generate_files(num_files: 15)
    return if Dir.exist?(TMP_DIR)

    # puts "  #{TMP_DIR}"
    num_files.times do
      filename = generate_random_filename
      FileUtils.mkdir_p(TMP_DIR)
      # puts "┝ #{filename}"
      FileUtils.touch("#{TMP_DIR}/#{filename}")
      # sleep 0.1
    end
  end

  def generate_random_filename
    separator = random_from(:separator)
    [
      random_from(:show_title),
      random_from(:season) + rand(1..20).to_s,
      random_from(:episode) + rand(1..13).to_s,
      random_from(:quality),
      random_from(:encoder),
      random_from(:codec)
    ].join(separator) + random_from(:extensions)
  end

  def random_from(key)
    FILE_PATTERNS.fetch(key).sample
  end

  def cleanup
    FileUtils.rm_rf(TMP_DIR)
  end

  def remove_valid_files
    files = Dir.entries(TMP_DIR)
    valid_files = files.select { |file| ['.mkv', '.avi', '.mp4'].include?(File.extname(file)) }
    valid_files.each { |file| FileUtils.rm(File.join(TMP_DIR, file)) }
  end
end

DummyFiles.generate_files(num_files: 30)
