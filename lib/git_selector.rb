# frozen_string_literal: true

require_relative './git_selector/version'
require_relative '../lib/git_prompt'

# Settings to load bundled gems
# require 'bundler/setup'
# Bundler.require(:default)

# :nocov:
module GitSelector
  def self.run
    GitPrompt.new
  end
end
# :nocov:
