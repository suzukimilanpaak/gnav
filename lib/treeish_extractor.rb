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
    get_treeish_names(cmd) do |line, names|
      names << line.strip
    end
  end

  def recent_branch_names
    cmd = 'git branch --sort=-committerdate'
    get_treeish_names(cmd) do |line, names|
      # a branch name with 'HEAD detached' means the current commit being worked on is detached from its HEAD
      unless line =~ /HEAD detached/
        # a branch name with '* ' is the current working one
        names << line.strip.sub('* ', '')
      end
    end
  end

  private

  def get_treeish_names(cmd)
    names = []
    _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
    stdout.each(sep="\n") do |line|
      yield(line, names)
    end
    names
  end
end
