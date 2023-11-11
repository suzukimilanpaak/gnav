# frozen_string_literal: true

require 'git'
require 'open3'

class TreeishExtractor
  attr_reader :git

  def initialize(git: nil)
    @git = git || Git.open(Dir.pwd)
  end

  def recent_tag_names
    cmd = 'git tag --sort=-committerdate'
    get_treeishes(cmd) do |line, names|
      names << {
        value: line.strip,
        name: line.strip
      }
    end
  end

  def recent_branch_names
    cmd = 'git branch --sort=-committerdate'
    get_treeishes(cmd) do |line, names|
      next if REJECT_STRATEGY.call(line, names).nil?
      names << {
        value: VALUE_STRATEGY.call(line, names),
        name: NAME_STRATEGY.call(line, names)
      }
    end
  end

  private

  REJECT_STRATEGY = lambda do |line, _|
    # 'HEAD detached' means the last commit is detached from its HEAD.
    # We don't need this information and remove it.
    line unless line =~ /HEAD detached/
  end
  VALUE_STRATEGY = lambda do |line, _|
    line.sub('*', '').strip
  end
  NAME_STRATEGY = lambda do |line, _|
    if line.match(/\*\s/)
      line.strip
    else
      "  #{line.sub('*', '').strip}"
    end
  end

  private_constant :REJECT_STRATEGY, :VALUE_STRATEGY, :NAME_STRATEGY

  def get_treeishes(cmd)
    names = []
    _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
    stdout.each(sep="\n") do |line|
      yield(line, names)
    end
    names
  end
end
