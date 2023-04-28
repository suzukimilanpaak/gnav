# frozen_string_literal: true

require 'bundler/setup'
require_relative './git_selector/version'
require_relative '../lib/git_prompt'

# Load bundled gems
Bundler.require(:default)

module GitSelector
  def self.run
    GitPrompt.new
  end
end
