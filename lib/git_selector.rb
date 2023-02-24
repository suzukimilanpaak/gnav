# frozen_string_litral: true

require_relative "./git_selector/version"
require_relative '../lib/selector'

# require 'bundler/setup'
# Bundler.require(:default)

Selector.new.select_tag
