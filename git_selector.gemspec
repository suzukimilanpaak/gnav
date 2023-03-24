require_relative 'lib/git_selector/version'

Gem::Specification.new do |spec|
  spec.name          = "git_selector"
  spec.version       = GitSelector::VERSION
  spec.authors       = ["Tatsuya Suzuki"]
  spec.email         = ["ttsysuzuki@googlemail.com"]

  spec.summary     = 'Interactive git tag and branch selector'
  spec.description = 'A CLI to let you interactive select tag and branch'
  spec.homepage    = 'https://github.com/suzukimilanpaak/git_selector'

  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/suzukimilanpaak/git_selector'
  spec.metadata["changelog_uri"] = 'https://github.com/suzukimilanpaak/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin/release'
  # spec.executables   = spec.files.grep(%r{^bin/release}) { |f| File.basename(f) }
  spec.executables   = ['gits']
  spec.require_paths = ["lib"]

  spec.add_dependency 'git'
  # see monkey_patches/tty/prompt.rb for more details
  spec.add_dependency 'tty-prompt', '>= 0.22.0', '< 0.24'
  spec.add_development_dependency 'rspec'
end
