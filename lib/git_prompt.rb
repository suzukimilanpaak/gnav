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
    display_select(:branch, extractor.recent_branch_names)
  end

  private

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
        display_select(:branch, extractor.recent_branch_names)
      end

      if event.value == 't'
        clear_prompt
        display_select(:tag, extractor.recent_tag_names)
      end
    end
  end

  def clear_prompt
    prompt.clear_list
  end

  def create_prompt
    @prompt = TTY::Prompt.new(quiet: false)
  end

  def display_select(treeish_type, treeish_names)
    message = prompt.decorate("Select #{treeish_type.to_s.capitalize} > ", :green)
    message += <<~MSG.chomp
      [b] branch view [t] tag view
      j: down, k: up, q: quit, Enter: choose tag
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
