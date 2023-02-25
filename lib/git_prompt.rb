# frozen_string_literal: true

require 'git'
require 'tty-prompt'
require 'logger'
require_relative './treeish_extractor'

class GitPrompt
  SELECT_OPTIONS_PER_PAGE = 10

  attr_reader :git, :extractor, :prompt, :logger

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
    @extractor = TreeishExtractor.new(git: git)
		@prompt = TTY::Prompt.new(quiet: true)

		define_key_events
    select_tag(extractor.recent_branch_names)
  end

  def define_key_events
    prompt.on(:keypress) do |event|
      if event.value == 'q'
        exit
      end

      if event.value == 'j'
        prompt.trigger(:keydown)
      end

      if event.value == 'k'
        prompt.trigger(:keyup)
      end


      if event.value == 'b'
        clear_prompt
        select_tag(extractor.recent_branch_names)
      end

      if event.value == 't'
        clear_prompt
        select_tag(extractor.recent_tag_names)
      end
    end
  end

  private

  def clear_prompt
    # 2 is for the prompt message
    prompt.print TTY::Cursor.clear_lines(SELECT_OPTIONS_PER_PAGE + 2, :up)
  end

  def select_tag(treeish_names)
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
    exit
  end

  def checkout(tag_name)
    git.checkout(tag_name)
  rescue Git::GitExecuteError => e
    prompt.error(e.message)
  end
end

