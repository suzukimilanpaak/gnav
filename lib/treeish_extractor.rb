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
    # reject commits without a tag
    selecting_rule = ->(line, names) do
      names << line.strip unless line =~ /-[\d]+-[a-z0-9]{8,}$/
    end
    get_treeish_names(cmd, selecting_rule)
  end

  def recent_branch_names
    # TODO limit number of branches when arg is not given
    cmd = 'git branch --sort=-committerdate'
    # a current branch is prefixed with '* ' to indicate it's selected
    selecting_rule = ->(line, names) do
      names << line.strip.sub('* ', '') unless line =~ /HEAD detached/
    end
    get_treeish_names(cmd, selecting_rule)
  end

  private

  def get_treeish_names(cmd, selecting_rule)
    names = []
    _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
    stdout.each(sep="\n") do |line|
      selecting_rule.call(line, names)
    end
    names
  end
end
