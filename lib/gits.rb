# frozen_string_litral: true

require 'git'
require 'tty/prompt/vim'
require 'logger'

# require 'bundler/setup'
# Bundler.require(:development)

class TagExtractor
  attr_reader :git, :shas_names

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd, log: Logger.new(STDOUT))
  end

  def recent_commits_with_tags
    git.log(100).each_with_object({}) do |commit, sum|
      tag_names = shas_names[commit.sha]
      sum[commit] = tag_names if tag_names
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

# puts TagExtractor.new.recent_commits_with_tags.map {|k, v| v }

git = Git.open(Dir.pwd, log: Logger.new(STDOUT))
extractor = TagExtractor.new(git: git)
prompt = TTY::Prompt.new
selected = prompt.select('j: down, k: up, enter: choose') do |menu|
  extractor.recent_commits_with_tags.each do |commit, tag_names|
    tag_names.each do |tag_name|
      menu.choice tag_name, -> { git.checkout(tag_name) }
    end
  end
end

puts selected
