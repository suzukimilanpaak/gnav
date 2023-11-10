# frozen_string_literal: true

require_relative './gnav/version'
require_relative '../lib/git_prompt'

module GNav
  def self.run
    GitPrompt.new
  end
end
