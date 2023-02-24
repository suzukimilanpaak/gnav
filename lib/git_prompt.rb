# frozen_string_literal: true

require 'git'
require 'tty/prompt/vim'
require 'logger'
require_relative './tag_extractor'

class GitPrompt
  attr_reader :git, :extractor, :prompt, :logger

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
    @extractor = TagExtractor.new(git: git)
    @prompt = TTY::Prompt.new

    define_key_events
  end

  def select_tag
    message = 'j/↓: down, k/↑: up, Enter: choose tag, Type to filter tags'
    prompt.select(message, filter: true, per_page: 10) do |menu|
      extractor.recent_tag_names.each do |tag_name|
        menu.choice tag_name, -> { checkout(tag_name) }
      end
    end
  rescue TTY::Reader::InputInterrupt => e
    exit
  end

  def define_key_events
    prompt.on(:keypress) do |event|
      if event.value == "j"
        prompt.trigger(:keydown)
      end

      if event.value == "k"
        prompt.trigger(:keyup)
      end

      if event.value == "q"
        exit
      end
    end
  end

  private

  def checkout(tag_name)
    git.checkout(tag_name)
  rescue Git::GitExecuteError => e
    prompt.error(e.message)
  end
end

