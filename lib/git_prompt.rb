# frozen_string_literal: true

require 'git'
require 'tty-prompt'
require 'logger'
require_relative './treeish_extractor'
require_relative './monkey_patches/tty/prompt.rb'

class GitPrompt
  SELECT_OPTIONS_PER_PAGE = 10

  attr_reader :git, :extractor, :prompt, :logger

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
    @extractor = TreeishExtractor.new(git: git)

    create_prompt
    define_key_events
    display_select(extractor.recent_branch_names)
  end

  def define_key_events
    prompt.on(:keypress) do |event|
      if event.value == 'q'
        exit
      end

      # move up/down in the list

      if event.value == 'j'
        prompt.trigger(:keydown)
      end

      if event.value == 'k'
        prompt.trigger(:keyup)
      end

      # Select a mode

      if event.value == 'b'
        clear_prompt
        display_select(extractor.recent_branch_names)
      end

      if event.value == 't'
        clear_prompt
        display_select(extractor.recent_tag_names)
      end
    end
  end

  private

  def clear_prompt
    prompt.clear_list
  end

  def create_prompt
    @prompt = TTY::Prompt.new(quiet: true)
  end

  def display_select(treeish_names)
    message = <<~MSG.chomp
      j: down, k: up, q: quit, Enter: choose tag
      [b] branch mode [t] tag mode
    MSG

    if treeish_names.size > 0
      prompt.select(message, filter: false, per_page: SELECT_OPTIONS_PER_PAGE) do |menu|
        treeish_names.each do |tag_name|
          menu.choice tag_name, -> { checkout(tag_name) }
        end
      end
    else
      prompt.ok 'No tags were found'
    end
  rescue TTY::Reader::InputInterrupt => e
    # exit automatically
  end

  def checkout(tag_name)
    git.checkout(tag_name)
    exit
  rescue Git::GitExecuteError => e
    prompt.error(e.message)
  end
end
