# frozen_string_literal: true

require 'git'
require 'tty-prompt'
require 'logger'
require_relative './treeish'
require_relative './monkey_patches/tty/prompt'

class GitPrompt
  SELECT_OPTIONS_PER_PAGE = 10

  attr_reader :git, :branch, :tag, :prompt, :logger

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
    @branch = Treeish::Branch.new(git: git)
    @tag = Treeish::Tag.new(git: git)

    create_prompt
    define_key_events
    display_select(:branch, branch.recents)
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
        prompt.clear!
        display_select(:branch, branch.recents)
      end

      if event.value == 't'
        prompt.clear!
        display_select(:tag, tag.recents)
      end
    end
  end

  def create_prompt
    @prompt = TTY::Prompt.new(quiet: false)
  end

  def display_select(treeish_type, treeishes)
    message = prompt.decorate("Select #{treeish_type.to_s.capitalize} > ", :green)
    message += <<~MSG.chomp
      [b] branch view [t] tag view
      j: down, k: up, q: quit, Enter: choose tag
    MSG

    if treeishes.size > 0
      prompt.select(message, filter: false, per_page: SELECT_OPTIONS_PER_PAGE) do |menu|
        treeishes.each do |treeish|
          menu.choice(treeish[:name], -> { checkout(treeish[:value]) })
        end
      end
    else
      prompt.ok 'No tags were found'
    end
  rescue TTY::Reader::InputInterrupt => e
    # exit automatically
  end

  def checkout(treeish_name)
    git.checkout(treeish_name)
    exit
  rescue Git::GitExecuteError => e
    prompt.error(e.message)
  end
end
