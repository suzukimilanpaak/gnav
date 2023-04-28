# frozen_string_literal: true

require_relative '../../git_prompt.rb'

module TTY
  # original - https://github.com/piotrmurach/tty-prompt/blob/master/lib/tty/prompt.rb
  class Prompt
    # :nocov:
    def clear!
      # 2 is for the prompt message
      print(TTY::Cursor.clear_lines(GitPrompt::SELECT_OPTIONS_PER_PAGE + 2, :up))
    end
    # :nocov:
  end
end
