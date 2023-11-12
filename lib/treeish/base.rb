# frozen_string_literal: true

require 'git'
require 'open3'

module Treeish
  class Base
    attr_reader :git

    def initialize(git: nil)
      @git = git || Git.open(Dir.pwd)
    end

    def recents
      get_treeishes(recents_command) do |line, names|
        next if reject_strategy(line, names)
        names << {
          value: value_strategy(line, names),
          name: name_strategy(line, names)
        }
      end
    end

    private

    def recents_command; end
    def reject_strategy(line, names); end
    def value_strategy(line, names); end
    def name_strategy(line, names); end

    def get_treeishes(cmd)
      names = []
      _stdin, stdout, _stderr, _wait_thr = Open3.popen3(cmd)
      stdout.each(sep="\n") do |line|
        yield(line, names)
      end
      names
    end
  end
end
