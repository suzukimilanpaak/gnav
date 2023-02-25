# frozen_string_literal: true

require_relative '../../git_prompt.rb'
require_relative './prompt/list.rb'

module TTY
  class Prompt

    # original - https://github.com/piotrmurach/tty-prompt/blob/master/lib/tty/prompt.rb#L226-L250
    def invoke_select(object, question, *args, &block)
      options = Utils.extract_options!(args)
      choices = if args.empty? && !block
                  possible = options.dup
                  options = {}
                  possible
                elsif args.size == 1 && args[0].is_a?(Hash)
                  Utils.extract_options!(args)
                else
                  args.flatten
                end

      @list = object.new(self, **options)
      @list.(question, choices, &block)
    end

    def unsubscribe_list
      self.unsubscribe(@list)
    end

    def clear_list
      @done = true
      # @list = nil
      unsubscribe_list
      # 2 is for the prompt message
      print(TTY::Cursor.clear_lines(GitPrompt::SELECT_OPTIONS_PER_PAGE + 2, :up))
    end

    def purge_list
      @list = nil
    end
  end
end
