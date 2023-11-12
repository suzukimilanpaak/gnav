# frozen_string_literal: true

require_relative './base'

module Treeish
  class Tag < Base
    private

    def recents_command
      'git tag --sort=-committerdate'
    end

    def reject_strategy(line, _)
      false
    end

    def value_strategy(line, _)
      line.strip
    end

    def name_strategy(line, _)
      if line.match(/^#{current}$/)
        "* #{line.strip}"
      else
        "  #{line.strip}"
      end
    end

    def current
      # git describe --exact-match --tags $(git log -n1 --pretty='%h')
      cmd = "git log -n1 --pretty='%h'"
      _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
      last_commit = stdout.read.strip

      cmd = "git describe --exact-match --tags #{last_commit}"
      _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
      stdout.read.strip || '[\s]+'
    end
  end
end
