# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'southsync'
require 'southsync/utilities'
require 'southsync/config'

require_relative 'support/dummy_generator'
