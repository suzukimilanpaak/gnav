# frozen_string_litral: true

require 'tty/prompt/vim'

prompt = TTY::Prompt.new
prompt.select("Choose your destiny?") do |menu|
  menu.choice 'Scorpion', 1
  menu.choice name: 'Kano',disabled: '(Cant use Kano)'
  menu.choice 'Jax', -> { 'Nice choice captain!' }
end
