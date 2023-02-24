# frozen_string_litral: true

require 'git'
require 'tty/prompt/vim'
require 'logger'
require 'open3'

# require 'bundler/setup'
# Bundler.require(:development)

require 'pry'

class TagExtractor
  attr_reader :git, :shas_names

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
  end

  # def recent_tags_with_commit
  #   commits_names = recent_tag_names.each_with_object({}) do |tag_name, sum|
  #     sum[tag_name] = git.object(tag_name) if git.object(tag_name).commit?
  #   end
  # end

  def recent_tag_names
    if head_changed?
      tag_names = []
      cmd = "git describe --tags $(git rev-list --tags --max-count=1000)"
      _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
      stdout.each(sep="\n") do |line|
        # reject rev without a tag
        tag_names << line.chomp unless line =~ /-[\d]+-[a-z0-9]{8,}$/
      end
      @tag_names = tag_names
    else
      @tag_names
    end
  end

  private

  def shas_names
    if head_changed?
      @shas_names = git.tags.each_with_object({}) { |t, sum| (sum[t.sha] ||= []) << t.name }
    else
      @shas_names
    end
  end

  def head_changed?
    changed = (@head_sha != git.log(1).first.sha)
    @head_sha = git.log(1).first.sha
    changed
  end
end

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

Selector.new.select_tag
