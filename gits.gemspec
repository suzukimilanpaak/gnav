# frozen_string_litral: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'gits'
  s.version     = '0.0.0'
  s.authors     = 'Tatsuya Suzuki'
  s.homepage    = 'https://github.com/suzukimilanpaak/gits'
  s.summary     = 'Interactive git tag and branch selector'
  s.description = 'A CLI to let you interactive select tag and branch'

  s.files = Dir['{app,config,db,lib,vendor}/**/*'] + ['README.md']

  s.add_dependency 'git'
  s.add_dependency 'tty-prompt-vim'

  s.add_development_dependency 'rspec'
end
