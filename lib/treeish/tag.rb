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
      line.strip
    end

    def current
      # git describe --exact-match --tags $(git log -n1 --pretty='%h')
      last_commit = "git log -n1 --pretty='%h'"
      git.describe(last_commit, { exact_match:nil, tags: nil })
    end
  end
end
