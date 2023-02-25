# frozen_string_literal: true

require 'git'
require 'open3'

class TreeishExtractor
  attr_reader :git

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
  end

  def recent_tag_names
    # TODO unlimit number of tags when arg is given
    cmd = "git describe --tags $(git rev-list --tags --max-count=1000)"
    get_treeish_names(cmd)
  end

  def recent_branch_names
    # TODO limit number of branches when arg is not given
    cmd = 'git branch --sort=-committerdate'
    get_treeish_names(cmd)
  end

  private

  def get_treeish_names(cmd)
    names = []
    _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
    stdout.each(sep="\n") do |line|
      # reject rev without a tag
      # current branch has '* ' to indicate it's selected
      names << line.strip.sub('* ', '') unless line =~ /-[\d]+-[a-z0-9]{8,}$/
    end
    names
  end
end
