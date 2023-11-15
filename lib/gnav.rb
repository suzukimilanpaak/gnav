# frozen_string_literal: true

require 'cli'
require_relative './gnav/version'
require_relative '../lib/git_prompt'

file = File.expand_path('../../', __FILE__)
gemspec = Gem::Specification::load("#{file}/gnav.gemspec")
CLI.new do
  description gemspec.description
  version gemspec.version
end.parse!

module GNav
  def self.run
    GitPrompt.new
  end
end
