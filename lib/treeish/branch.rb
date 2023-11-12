# frozen_string_literal: true

require_relative './base'

module Treeish
  class Branch < Base
    private

    def recents_command
      'git branch --sort=-committerdate'
    end

    def reject_strategy(line, _)
      # 'HEAD detached' means the last commit is detached from its HEAD.
      # We don't need this information and remove it.
      line =~ /HEAD detached/
    end

    def value_strategy(line, _)
      line.sub('*', '').strip
    end

    def name_strategy(line, _)
      if line.match(/\*\s/)
        line.strip
      else
        "  #{line.strip}"
      end
    end
  end
end
