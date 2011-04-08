# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hangover/version"

Gem::Specification.new do |s|
  s.name        = "hangover"
  s.version     = Hangover::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Norman Timmler"]
  s.email       = ["norman.timmler@gmail.com"]
  s.homepage    = "http://github.com/unnu/hangover"
  s.summary     = %q{Hangover is time travel for your source code directory.}
  s.description = %q{Some call it the unlimited undo. It tracks every single file change in a git repository. Hangover runs in the background. The file changes get committed to the next parent hangover repository. You can restore any state of your files from the moment on you started hangover.}

  s.rubyforge_project = "hangover"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "rb-fsevent", ">=0.4.0"
  s.add_dependency "i18n", ">=0.5.0"
  s.add_dependency "activesupport", ">=3.0.3"
end
