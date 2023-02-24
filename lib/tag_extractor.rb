# frozen_string_literal: true

require 'git'
require 'open3'

class TagExtractor
  attr_reader :git, :shas_names

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
  end

  def recent_tag_names
    if head_changed?
      tag_names = []
      # TODO unlimit tags when arg is given
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

