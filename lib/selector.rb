# frozen_string_literal: true

require 'git'
require 'tty/prompt/vim'
require_relative './tag_extractor'

class Selector
  attr_reader :git, :extractor, :prompt

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
    @extractor = TagExtractor.new(git: git)
    @prompt = TTY::Prompt.new
  end

  def select_tag
    message = 'j/↓: down, k/↑: up, Enter: choose tag, Type to filter tags'
    prompt.select(message, filter: true, per_page: 10) do |menu|
      extractor.recent_tag_names.each do |tag_name|
        menu.choice tag_name, -> { checkout(tag_name) }
      end
    end
  end

  private

  def checkout(tag_name)
    git.checkout(tag_name)
  rescue Git::GitExecuteError => e
    puts e.message
  end
end

